# Summarizes an xcodebuild log as Markdown: the result, errors by module, the APIs reported as unavailable at the
# deployment target, and the other errors.
#
#   summarize.py LOG SRC NAME STATUS SECONDS NOTE SETTINGS
import collections
import os
import re
import sys

log_path, src, name, status, seconds, note, settings = sys.argv[1:8]
src = os.path.realpath(src)
lines = open(log_path, errors="replace").read().splitlines()

error_line = re.compile(r"^(/[^:]+):(\d+):(\d+): error: (.*)$")
unavailable = re.compile(r"'?([^' ]+)'? is only available in macOS (\d+(?:\.\d+)*) or newer")


def module_of(path):
    path = os.path.realpath(path)
    if "/SourcePackages/checkouts/" in path:
        return "dependency " + path.split("/SourcePackages/checkouts/")[1].split("/")[0]
    rel = os.path.relpath(path, src) if path.startswith(src) else path
    parts = rel.split("/")
    if parts[0] == "Packages" and len(parts) > 3:
        return parts[3] if parts[2] == "Sources" else parts[1] + " " + parts[2]
    if parts[0] == "tests":
        return "tests/" + parts[1]
    if parts[0] == "LightTouchMac":
        return "app"
    return parts[0]


def display(path):
    path = os.path.realpath(path)
    if "/SourcePackages/checkouts/" in path:
        return path.split("/SourcePackages/checkouts/")[1]
    return os.path.relpath(path, src) if path.startswith(src) else path


errors = sorted({m.groups() for m in map(error_line.match, lines) if m})
by_module = collections.Counter(module_of(e[0]) for e in errors)
apis = collections.defaultdict(set)
other = []
for path, line, _, message in errors:
    m = unavailable.search(message)
    if m:
        apis[(m.group(2), m.group(1))].add(f"{display(path)}:{line}")
    else:
        other.append(f"{display(path)}:{line}: {message}")

result = next((l.strip() for l in reversed(lines) if l.startswith("** BUILD")), "no BUILD line")
failed = []
if "The following build commands failed:" in lines:
    i = lines.index("The following build commands failed:") + 1
    while i < len(lines) and lines[i].startswith("\t"):
        failed.append(lines[i].strip())
        i += 1

print(f"## {name}: {result} (exit {status}, {seconds}s)")
print(f"\nSettings: `{settings or 'none'}`. {note}")
print(f"\n{len(errors)} distinct errors.")
if by_module:
    print("\n| Module | Errors |\n|---|---|")
    for module, count in by_module.most_common():
        print(f"| {module} | {count} |")
if apis:
    print("\n### Unavailable at the deployment target\n\n| macOS | API | Sites |\n|---|---|---|")
    for (version, api), sites in sorted(apis.items(), key=lambda kv: (-float(kv[0][0].split(".")[0]), kv[0][1])):
        shown = ", ".join(sorted(sites)[:4]) + (f" (+{len(sites) - 4})" if len(sites) > 4 else "")
        print(f"| {version} | `{api}` | {shown} |")
if other:
    print("\n### Other errors (first 60)\n")
    for entry in other[:60]:
        print(f"- `{entry}`")
if failed:
    print("\n### Failed build commands (first 30)\n")
    for entry in failed[:30]:
        print(f"- {entry}")
if not errors and "BUILD SUCCEEDED" not in result:
    print("\n### Log tail\n\n```")
    print("\n".join(lines[-40:]))
    print("```")
