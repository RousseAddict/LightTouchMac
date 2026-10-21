# The port's mechanical rewrites of a fresh upstream checkout (apply.sh's third step). It prints each rule's count and
# exits 1 when a required rule matched nothing, which means upstream moved what the rule rewrites.
#
# 1. Text rules: regular-expression replacements over fixed files (deployment target, project format, package
#    references) or over the Swift code in SWIFT_ROOTS (APIs renamed to the compat modules' equivalents). A Swift file
#    a rename changes also gets that module's import.
# 2. Manifests: a block appended to each Package.swift adjusts the `package` value in Swift:
#    - the platform becomes macOS 11;
#    - swift-subprocess resolves to the port's local stand-in;
#    - each target with a rewritten file depends on the compat module that file now imports.
#    Doing this Swift-side survives any formatting upstream gives the manifest.
#
#   codemod.py UPSTREAM_CHECKOUT
import collections
import json
import os
import re
import sys
from dataclasses import dataclass

# The Swift code the renames apply to: what ships, its packages' tests, and tests/offline (whose symlinks into the app
# resolve to files covered here). tests/sessions, tools, BuildTools and ReleaseChecks run on the CI host only and
# keep upstream's APIs.
SWIFT_ROOTS = [
    "LightTouchMac",
    "LightTouchDevice",
    "LightTouchServices",
    "Packages/HostRuntime",
    "Packages/DeviceRuntime",
    "Packages/DeviceServices",
    "Packages/FirmwareKit",
    "Packages/LightTouchCore",
    "tests/offline",
]
# The port's own code (apply.sh adds it first), which the rules leave alone.
OWN = [
    "Packages/BigSurCompat",
    "Packages/ObservationCompat",
    "Packages/BigSur",
    "LightTouchMac/BigSur",
    "Packages/LightTouchCore/Sources/LightTouchCore/BigSur",
]
MEDIA = [
    "Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaSong.swift",
    "Packages/LightTouchCore/Sources/LightTouchCore/Features/MediaVideo.swift",
]
# Packages whose platform drops to macOS 11 (they ship); the test and tooling packages keep theirs.
SHIPPED = ["HostRuntime", "DeviceRuntime", "DeviceServices", "FirmwareKit", "LightTouchCore"]
COMPAT_PACKAGES = {"BigSurCompat": "Packages/BigSurCompat", "ObservationCompat": "Packages/ObservationCompat"}
PROJECT = "LightTouchMac.xcodeproj/project.pbxproj"
SWIFT = "swift"
APP = "app"  # the Swift files of the app target (LightTouchMac/)
SWIFTUI = "swiftui"  # the app's Swift files that import SwiftUI
# The app's own compat files (add/LightTouchMac/BigSur), linked into each tests/offline target that compiles app files.
APP_COMPAT = [
    "LightTouchMac/BigSur/AppKitCompat.swift",
    "LightTouchMac/BigSur/MapKitCompat.swift",
    "LightTouchMac/BigSur/SwiftUICompat.swift",
]


@dataclass
class Rule:
    name: str
    files: object  # a list of paths relative to the checkout, or SWIFT
    pattern: str
    replacement: object  # a string with \1-style groups, or a function of the match
    module: str = ""  # imported by Swift files this rule changes
    required: bool = True


def local_package(name, url_part, path):
    """The project's remote reference to a package, made local; the object ID, and so every use of it, stays."""
    return Rule(
        f"project: {name} as a local package",
        [PROJECT],
        r'isa = XCRemoteSwiftPackageReference;\s*repositoryURL = "[^"]*' + re.escape(url_part)
        + r'[^"]*";\s*requirement = \{[^}]*\};',
        f"isa = XCLocalSwiftPackageReference;\n\t\t\trelativePath = {path};",
    )


def foreground_style(text):
    """`.foregroundStyle(style)` to `.compatForegroundStyle(color)`: the hierarchical styles that aren't Colors become
    the label colors they stand for. Left alone when it takes an AnyShapeStyle (a hand patch's)."""
    out, i, rewritten = [], 0, 0
    while True:
        j = text.find(".foregroundStyle(", i)
        if j < 0:
            return "".join(out) + text[i:], rewritten
        start = j + len(".foregroundStyle(")
        depth, k = 1, start
        while depth and k < len(text):
            depth += {"(": 1, ")": -1}.get(text[k], 0)
            k += 1
        argument = text[start:k - 1]
        if "AnyShapeStyle" in argument:
            out.append(text[i:k])
        else:
            argument = re.sub(r"(?<![\w)])\.tertiary\b", ".compatTertiary", argument)
            argument = re.sub(r"(?<![\w)])\.quaternary\b", ".compatQuaternary", argument)
            argument = re.sub(r"(?<![\w)])\.tint\b", ".accentColor", argument)
            out.append(text[i:j] + ".compatForegroundStyle(" + argument + ")")
            rewritten += 1
        i = k


# SF Symbols missing on macOS 11.7 (checked on the Big Sur Mac), and stand-ins it has.
SYMBOLS = {"document.on.document": "doc.on.doc", "inset.filled.bottomthird.square": "rectangle.bottomthird.inset.fill"}

RULES = [
    Rule("xcconfig: macOS 11", ["Configuration/Shared.xcconfig"],
         r"^MACOSX_DEPLOYMENT_TARGET = 14\.4$", "MACOSX_DEPLOYMENT_TARGET = 11.0"),
    Rule("project: macOS 11", [PROJECT], r"MACOSX_DEPLOYMENT_TARGET = 14\.4;", "MACOSX_DEPLOYMENT_TARGET = 11.0;"),
    # Xcode 27's format; GitHub's newest Xcode is 26, which opens 77 and builds the project unchanged.
    Rule("project: objectVersion 77", [PROJECT], r"objectVersion = 1\d\d;", "objectVersion = 77;"),
    local_package("swift-subprocess", "swift-subprocess", "Packages/BigSur/swift-subprocess"),
    local_package("Sparkle", "sparkle-project/Sparkle", "Packages/BigSur/Sparkle"),
    # The native build (scripts/vendor): every host binary built for macOS 11, and checked against it (minos, no weak
    # imports), as the release build holds them to 14.
    Rule("native: compiler and linker minimums",
         ["scripts/build-package-native.sh", "scripts/build-static-deps.sh", "scripts/build-iboot32patcher.sh"],
         r"(-mmacosx-version-min=|MACOSX_DEPLOYMENT_TARGET=)14\.0\b", r"\g<1>11.0"),
    Rule("native: iBoot32Patcher's Mach-O check", ["scripts/build-iboot32patcher.sh"], r"--minos 14\.0\b", "--minos 11.0"),
    Rule("native: the vendor build's Mach-O check", ["Packages/BuildTools/Sources/BuildTools/Vendor.swift"],
         r'\bminos = "14\.4"', 'minos = "11.0"'),
    Rule("native: check-macho's default", ["Packages/BuildTools/Sources/ltm-build/main.swift"],
         r'@Option var minos = "14\.0"', '@Option var minos = "11.0"'),
    Rule("native: the recorded deployment target",
         ["Packages/BuildTools/Sources/BuildTools/Records.swift", "build-support/dependencies.json"],
         r'(\["deployment_target"\] = |"macos_deployment_target": )"14\.0"', r'\g<1>"11.0"'),
    # SwiftUI 3-5 (macOS 12-14), in the app's views: LightTouchMac/BigSur/SwiftUICompat.swift.
    Rule("swiftui: @Bindable", SWIFTUI, r"@Bindable\b", "@CompatBindable"),
    Rule("swiftui: .textSelection(.enabled)", SWIFTUI, r"\.textSelection\(\.enabled\)", ".compatTextSelectionEnabled()"),
    Rule("swiftui: .monospacedDigit()", SWIFTUI, r"\.monospacedDigit\(\)", ".compatMonospacedDigit()"),
    Rule("swiftui: .task", SWIFTUI, r"\.task(\s*\{|\(id:|\(priority:)", r".compatTask\1"),
    Rule("swiftui: .formStyle(.grouped)", SWIFTUI, r"\.formStyle\(\.grouped\)", ".compatGroupedFormStyle()"),
    Rule("swiftui: .scrollDisabled", SWIFTUI, r"\.scrollDisabled\(", ".compatScrollDisabled("),
    Rule("swiftui: .onGeometryChange", SWIFTUI, r"\.onGeometryChange\(for:", ".compatOnGeometryChange(for:"),
    Rule("swiftui: .onChange(of:)", SWIFTUI, r"\.onChange\(of:", ".compatOnChange(of:"),
    Rule("swiftui: LabeledContent", SWIFTUI, r"(?<![.\w])LabeledContent\b", "CompatLabeledContent"),
    Rule("swiftui: NavigationSplitView", SWIFTUI, r"(?<![.\w])NavigationSplitView\b", "CompatNavigationSplitView"),
    Rule("swiftui: .navigationSplitViewColumnWidth", SWIFTUI, r"\.navigationSplitViewColumnWidth\(",
         ".compatNavigationSplitViewColumnWidth("),
    Rule("swiftui: Section(title)", SWIFTUI, r'Section\(("[^"]*"|[A-Za-z_][\w.]*)\)(\s*)\{',
         r"Section(header: Text(\1))\2{"),
    Rule("swiftui: .fileDialogDefaultDirectory", SWIFTUI, r"\.fileDialogDefaultDirectory\(",
         ".compatFileDialogDefaultDirectory("),
    Rule("swiftui: .foregroundStyle", SWIFTUI, r"\.foregroundStyle\(", foreground_style),
    Rule("swiftui: Grid", SWIFTUI, r"(?<![.\w])Grid\b", "CompatGrid"),
    Rule("swiftui: GridRow", SWIFTUI, r"(?<![.\w])GridRow\b", "CompatGridRow"),
    Rule("swiftui: .gridColumnAlignment", SWIFTUI, r"\.gridColumnAlignment\(", ".compatGridColumnAlignment("),
    Rule("swiftui: .background(.quaternary, in:)", SWIFTUI, r"\.background\(\.quaternary, in:",
         ".compatBackground(.compatQuaternary, in:"),
    Rule("swiftui: .selectionDisabled", SWIFTUI, r"\.selectionDisabled\(", ".compatSelectionDisabled("),
    Rule("swiftui: .contextMenu(forSelectionType:)", SWIFTUI, r"\.contextMenu\((\s*)forSelectionType:",
         r".compatContextMenu(\1forSelectionType:"),
    # Every view follows ObservationCompat models through CompatObserving (SwiftUI only tracks Observation's).
    Rule("swiftui: views observe ObservationCompat models", SWIFTUI,
         r"^([ \t]*)((?:(?:public|private|fileprivate|internal) )?)var body: some View \{",
         r"\1\2var body: some View { CompatObserving { observedBody } }\n\1@ViewBuilder \2var observedBody: some View {"),
    Rule("app: urlsForApplications(toOpen:)", APP, r"\.urlsForApplications\(toOpen:", ".compatURLsForApplications(toOpen:"),
    # AppKit (macOS 14), in the app: LightTouchMac/BigSur/AppKitCompat.swift.
    Rule("app: .inspectorTrackingSeparator", APP, r"\.inspectorTrackingSeparator\b", ".compatInspectorTrackingSeparator"),
    Rule("app: .toggleInspector", APP, r"\.toggleInspector\b", ".compatToggleInspector"),
    Rule("app: sectionHeader(title:)", APP, r"\.sectionHeader\(title:", ".compatSectionHeader(title:"),
    Rule("app: loadViewIfNeeded()", APP, r"\bloadViewIfNeeded\(\)", "compatLoadViewIfNeeded()"),
    Rule("app: NSColor.systemFill", APP, r"\bNSColor\.systemFill\b", "NSColor.compatSystemFill"),
    # macOS 13 time and lock APIs.
    Rule("swift: Duration", SWIFT, r"\bDuration\b", "CompatDuration", "BigSurCompat"),
    Rule("swift: ContinuousClock", SWIFT, r"\bContinuousClock\b", "CompatContinuousClock", "BigSurCompat"),
    Rule("swift: SuspendingClock", SWIFT, r"\bSuspendingClock\b", "CompatSuspendingClock", "BigSurCompat"),
    Rule("swift: Task.sleep(for:)", SWIFT, r"\bTask\.sleep\((\s*)for:", r"Task.compatSleep(\1for:", "BigSurCompat"),
    Rule("swift: OSAllocatedUnfairLock", SWIFT, r"\bOSAllocatedUnfairLock\b", "CompatUnfairLock", "BigSurCompat"),
    Rule("swift: .formatted(.byteCount(style: .file))", SWIFT, r"\.formatted\(\.byteCount\(style: \.file\)\)",
         ".compatFileBytes()", "BigSurCompat"),
    Rule("swift: .formatted(date:time:)", SWIFT, r"\.formatted\(date:", ".compatFormatted(date:", "BigSurCompat"),
    Rule("swift: firstRange(of:)", SWIFT, r"\.firstRange\(of:", ".compatFirstRange(of:", "BigSurCompat"),
    Rule("swift: TimeZone.gmt", SWIFT, r"(?<=[\s(:,=])\.gmt\b", ".compatGMT", "BigSurCompat"),
    # URLSession's async calls (macOS 12): BigSurCompat's URLSessionCompat.
    Rule("swift: URLSession data(for:)", SWIFT, r"\bURLSession\.shared\.data\(for:", "URLSession.shared.compatData(for:",
         "BigSurCompat"),
    Rule("swift: URLSession download(for:delegate:)", SWIFT, r"\bURLSession\.shared\.download\((\s*)for:",
         r"URLSession.shared.compatDownload(\1for:", "BigSurCompat"),
    # AVFoundation's async loading (macOS 12): LightTouchCore's BigSur/AVAssetCompat.swift.
    Rule("media: load(.property)", MEDIA, r"\.load\(\.", ".compatLoad(."),
    Rule("media: loadTracks(withMediaType:)", MEDIA, r"\.loadTracks\(withMediaType:", ".compatLoadTracks(withMediaType:"),
    # Observation (macOS 14): Swift 6.2's own, ported for macOS 11 as ObservationCompat.
    Rule("swift: import Observation", SWIFT, r"^import Observation$", "import ObservationCompat"),
    Rule("swift: @Observable", SWIFT, r"@Observable\b", "@CompatObservable", "ObservationCompat"),
    Rule("swift: @ObservationIgnored", SWIFT, r"@ObservationIgnored\b", "@CompatObservationIgnored",
         "ObservationCompat"),
    Rule("swift: withObservationTracking", SWIFT, r"\bwithObservationTracking\b", "withCompatObservationTracking",
         "ObservationCompat"),
    Rule("swift: SF Symbols", SWIFT, r'"(' + "|".join(map(re.escape, SYMBOLS)) + r')"',
         lambda m: f'"{SYMBOLS[m.group(1)]}"', required=False),
]


# Xcode 27's Icon Composer keys, which Xcode 26's actool throws on ("attempt to insert nil object"); macOS 11 shows the
# flat icon, which doesn't use them.
ICON = "LightTouchMac/LightTouch.icon/icon.json"
ICON_KEYS = ("features", "refractivity", "blur-material")


def icon_for_xcode26(root):
    """Drops Xcode 27-only keys from the app icon's manifest; returns how many it removed."""
    path = os.path.join(root, ICON)
    if not os.path.exists(path):
        return 0
    removed = 0

    def strip(node):
        nonlocal removed
        if isinstance(node, dict):
            for key in ICON_KEYS:
                if key in node:
                    del node[key]
                    removed += 1
            for value in node.values():
                strip(value)
        elif isinstance(node, list):
            for value in node:
                strip(value)

    manifest = json.load(open(path))
    strip(manifest)
    with open(path, "w") as out:
        json.dump(manifest, out, indent=2, separators=(",", " : "), ensure_ascii=False)
        out.write("\n")
    return removed


def swift_files(root):
    """Real Swift files under SWIFT_ROOTS (not symlinks, not the port's own), and tests/offline's symlinks."""
    files, links = [], []
    for base in SWIFT_ROOTS:
        for directory, dirs, names in os.walk(os.path.join(root, base)):
            rel = os.path.relpath(directory, root)
            dirs[:] = sorted(d for d in dirs if d not in (".build", "build")
                             and not any(os.path.join(rel, d).startswith(own) for own in OWN))
            for name in names:
                path = os.path.join(directory, name)
                if not name.endswith(".swift") or name == "Package.swift":
                    continue
                (links if os.path.islink(path) else files).append(os.path.relpath(path, root))
    return sorted(files), sorted(links)


def add_import(text, module):
    """Adds `import module` before the first import that isn't inside an #if, unless the file has it already."""
    if re.search(rf"^(?:@\w+(?:\([^)]*\))? )*import {module}$", text, re.MULTILINE):
        return text
    lines = text.split("\n")
    depth, first = 0, None
    for i, line in enumerate(lines):
        stripped = line.strip()
        if stripped.startswith("#if"):
            depth += 1
        elif stripped.startswith("#endif"):
            depth -= 1
        elif depth == 0 and re.match(r"^(?:@\w+(?:\([^)]*\))? )*import \w+", stripped):
            first = i
            break
    if first is None:
        first = next((i for i, l in enumerate(lines) if l.strip() and not l.lstrip().startswith("//")), 0)
    lines.insert(first, f"import {module}")
    return "\n".join(lines)


def target_of(rel):
    """(package directory, target name) for a file in a Swift package, or None for the Xcode targets' files."""
    parts = rel.split("/")
    if parts[0] == "Packages" and len(parts) > 3 and parts[2] in ("Sources", "Tests"):
        return "/".join(parts[:2]), parts[3]
    if parts[:2] == ["tests", "offline"] and len(parts) > 3 and parts[2] in ("Sources", "Tests"):
        return "tests/offline", parts[3]
    return None


def manifest_block(package_dir, platform, subprocess, needs):
    lines = ["", "// Big Sur port (bigsur/apply.sh): adjusts the package above for macOS 11."]
    if platform:
        lines.append("package.platforms = [.macOS(.v11)]")
    if subprocess:
        lines += [
            "package.dependencies = package.dependencies.map { dependency in",
            '    guard case .sourceControl(_, let location, _) = dependency.kind, location.contains("swift-subprocess")',
            "    else { return dependency }",
            '    return .package(path: "' + os.path.relpath("Packages/BigSur/swift-subprocess", package_dir) + '")',
            "}",
        ]
    for module in sorted({m for modules in needs.values() for m in modules}):
        targets = sorted(t for t, modules in needs.items() if module in modules)
        path = os.path.relpath(COMPAT_PACKAGES[module], package_dir)
        lines.append(f'package.dependencies.append(.package(path: "{path}"))')
        lines.append("for target in package.targets where [" + ", ".join(f'"{t}"' for t in targets)
                     + "].contains(target.name) {")
        lines.append(f'    target.dependencies.append(.product(name: "{module}", package: "{module}"))')
        lines.append("}")
    return "\n".join(lines) + "\n"


def run(root):
    files, links = swift_files(root)
    imported = collections.defaultdict(set)  # file -> compat modules it now imports
    failed = []
    for rule in RULES:
        total = 0
        if rule.files == SWIFT:
            paths = files
        elif rule.files == APP:
            paths = [f for f in files if f.startswith("LightTouchMac/")]
        elif rule.files == SWIFTUI:
            paths = [f for f in files if f.startswith("LightTouchMac/")
                     and re.search(r"^import SwiftUI$", open(os.path.join(root, f)).read(), re.MULTILINE)]
        else:
            paths = rule.files
        for rel in paths:
            path = os.path.join(root, rel)
            if not os.path.exists(path):
                continue
            text = open(path).read()
            if rule.replacement is foreground_style:
                new, n = foreground_style(text)
            else:
                new, n = re.subn(rule.pattern, rule.replacement, text, flags=re.MULTILINE)
            if n:
                if rule.module:
                    new = add_import(new, rule.module)
                    imported[rel].add(rule.module)
                elif rule.name == "swift: import Observation":
                    imported[rel].add("ObservationCompat")
                with open(path, "w") as out:
                    out.write(new)
                total += n
        print(f"{total:5d}  {rule.name}")
        if rule.required and total == 0:
            failed.append(rule.name)

    print(f"{icon_for_xcode26(root):5d}  icon: Xcode 27 keys dropped for Xcode 26's actool")

    # Which targets import which compat module now, including tests/offline's targets through their symlinks.
    needs = collections.defaultdict(lambda: collections.defaultdict(set))
    for rel, modules in imported.items():
        owner = target_of(rel)
        if owner:
            needs[owner[0]][owner[1]] |= modules
    for link in links:
        real = os.path.relpath(os.path.realpath(os.path.join(root, link)), os.path.realpath(root))
        owner = target_of(link)
        if owner and real in imported:
            needs[owner[0]][owner[1]] |= imported[real]

    # tests/offline compiles app files through symlinks; the ones it compiles may use AppKitCompat's members.
    linked = 0
    app = os.path.realpath(os.path.join(root, "LightTouchMac")) + os.sep
    targets = {os.path.dirname(link) for link in links if os.path.realpath(os.path.join(root, link)).startswith(app)}
    for target in sorted(targets):
        # Hand patches add BigSurCompat imports to app files after this runs, and SwiftUICompat imports
        # ObservationCompat, so every such target gets both modules.
        owner = target_of(os.path.join(target, "x.swift"))
        if owner:
            needs[owner[0]][owner[1]] |= {"BigSurCompat", "ObservationCompat"}
        for compat in APP_COMPAT:
            destination = os.path.join(root, target, "BigSur" + os.path.basename(compat))
            if not os.path.lexists(destination):
                os.symlink(os.path.relpath(os.path.join(root, compat), os.path.join(root, target)), destination)
                linked += 1
    print(f"{linked:5d}  tests/offline: the app's compat files linked into the targets that compile app files")

    for package_dir in [f"Packages/{p}" for p in SHIPPED] + ["tests/offline"]:
        manifest = os.path.join(root, package_dir, "Package.swift")
        text = open(manifest).read()
        block = manifest_block(package_dir, package_dir.startswith("Packages/"),
                               "swift-subprocess" in text, needs.get(package_dir, {}))
        with open(manifest, "w") as out:
            out.write(text.rstrip("\n") + "\n" + block)
        targets = ", ".join(f"{t}: {'+'.join(sorted(m))}" for t, m in sorted(needs.get(package_dir, {}).items()))
        print(f"{'':5}  manifest: {package_dir} ({targets or 'platform only'})")

    if failed:
        print("\nRequired rules that matched nothing (upstream moved what they rewrite):", file=sys.stderr)
        for name in failed:
            print(f"  {name}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(run(sys.argv[1]))
