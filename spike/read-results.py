# Reads a run's results back from its notice annotations (spike/annotate.py), without signing in to GitHub, and
# prints them in order per job. Uses three to four anonymous API requests (60 an hour per address).
#
#   read-results.py RUN_ID [OWNER/REPO]
import json
import re
import sys
import urllib.request

run_id = sys.argv[1]
repo = sys.argv[2] if len(sys.argv) > 2 else "RousseAddict/LightTouchMac"


def get(path):
    request = urllib.request.Request(f"https://api.github.com/repos/{repo}/{path}",
                                     headers={"Accept": "application/vnd.github+json"})
    with urllib.request.urlopen(request) as response:
        return json.load(response)


chunk = re.compile(r"^(.*) \((\d+)/(\d+)\)$")
for job in get(f"actions/runs/{run_id}/jobs")["jobs"]:
    print(f"\n######## {job['name']}: {job['conclusion']}")
    notes = []
    for annotation in get(f"check-runs/{job['id']}/annotations?per_page=50"):
        m = chunk.match(annotation["title"] or "")
        if m:
            notes.append((m.group(1), int(m.group(2)), annotation["message"]))
        elif annotation["annotation_level"] != "notice" or "capacity" not in annotation["message"]:
            print(f"[{annotation['annotation_level']}] {annotation['message']}")
    for title, _, message in sorted(notes, key=lambda n: (n[0], n[1])):
        print(f"\n---- {title}\n{message}")
