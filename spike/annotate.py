# Publishes text files as workflow notice annotations, which anyone can read through the public API for a public
# repository (logs and artifacts need a signed-in account). Each file is split into chunks on line boundaries and
# titled "LABEL file (i/n)". A step keeps at most 10 notices, so the total is capped there.
#
#   annotate.py LABEL FILE...
import os
import sys

CHUNK = 30000
LIMIT = 10


def escape(text, title=False):
    text = text.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
    return text.replace(":", "%3A").replace(",", "%2C") if title else text


label, paths = sys.argv[1], sys.argv[2:]
notices = []
for path in paths:
    chunks, current = [], ""
    for line in open(path, errors="replace").read().splitlines(keepends=True):
        if current and len(current) + len(line) > CHUNK:
            chunks.append(current)
            current = ""
        current += line[:CHUNK]
    chunks.append(current)
    for i, chunk in enumerate(chunks, 1):
        notices.append((f"{label} {os.path.basename(path)} ({i}/{len(chunks)})", chunk))
for title, body in notices[:LIMIT]:
    print(f"::notice title={escape(title, title=True)}::{escape(body)}")
if len(notices) > LIMIT:
    print(f"::warning::{len(notices) - LIMIT} result chunks didn't fit in annotations; see the artifact.")
