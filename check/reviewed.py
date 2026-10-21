# The upstream releases and pins reviewed for compromise (reviewed.json, the organization's rule for open-source
# code). CI builds only those: the workflows default to the newest reviewed release and stop on anything unlisted.
#
#   reviewed.py newest REVIEWED            the newest reviewed release's tag
#   reviewed.py check REVIEWED CHECKOUT    exit 1, naming each, when the checkout's commit or a pin isn't reviewed
#   reviewed.py pins CHECKOUT              the checkout's commit and pins, as reviewed.json lists them
#
# CHECKOUT is an upstream checkout at the release's tag, before apply.sh.
import glob, hashlib, json, os, subprocess, sys


def pins(checkout):
    """The commit and what the vendor build and SwiftPM take from outside the repository."""
    commit = subprocess.run(["git", "-C", checkout, "rev-parse", "HEAD"], capture_output=True, text=True,
                            check=True).stdout.strip()
    sources = json.load(open(os.path.join(checkout, "build-support/sources.json")))
    swiftpm = set()
    for resolved in glob.glob(os.path.join(checkout, "**/Package.resolved"), recursive=True):
        if "/.build/" in resolved:
            continue
        for pin in json.load(open(resolved)).get("pins", []):
            swiftpm.add(f"{pin['identity']}@{pin['state'].get('revision')}")
    digest = lambda name: hashlib.sha256(open(os.path.join(checkout, "build-support", name), "rb").read()).hexdigest()
    return commit, {
        "qemu-ios": sources["qemu-ios"]["commit"],
        "usbmuxd": sources["usbmuxd"]["commit"],
        "dependencies.json": digest("dependencies.json"),
        "developer-disk-images.json": digest("developer-disk-images.json"),
    }, swiftpm


command = sys.argv[1] if len(sys.argv) > 1 else ""
if command == "newest":
    print(json.load(open(sys.argv[2]))["releases"][-1]["tag"])
elif command == "check":
    reviewed = json.load(open(sys.argv[2]))
    commit, found, swiftpm = pins(sys.argv[3])
    problems = []
    if commit not in {release["commit"] for release in reviewed["releases"]}:
        problems.append(f"upstream commit {commit} is no reviewed release")
    for name, value in found.items():
        if value not in reviewed["pins"][name]:
            problems.append(f"{name} {value} isn't reviewed")
    replaced = set(reviewed["swiftpm_replaced"])
    for pin in sorted(swiftpm):
        if pin.split("@")[0] not in replaced and pin not in reviewed["pins"]["swiftpm"]:
            problems.append(f"Swift package {pin} isn't reviewed")
    for problem in problems:
        print(f"::error::Not reviewed for compromise: {problem}. Review it, then add it to reviewed.json.")
    if not problems:
        print(f"{commit}: the release and its pins are reviewed")
    sys.exit(1 if problems else 0)
elif command == "pins":
    commit, found, swiftpm = pins(sys.argv[2])
    print(json.dumps({"commit": commit, "pins": found, "swiftpm": sorted(swiftpm)}, indent=1))
else:
    sys.exit("usage: reviewed.py newest REVIEWED | check REVIEWED CHECKOUT | pins CHECKOUT")
