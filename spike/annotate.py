# Publishes text files as workflow notice annotations: a short overview anyone can read through the public API (the
# full results are on the ci-results branch). GitHub keeps 4096 bytes of each message and 10 notices per step, so
# each file is split on line boundaries into chunks under 4000 bytes, titled "LABEL file (i/n)", and the total is
# capped at 10.
#
#   annotate.py LABEL FILE...
import os
import sys

CHUNK = 4000
LIMIT = 10


def escape(text, title=False):
    text = text.replace("%", "%25").replace("\r", "%0D").replace("\n", "%0A")
    return text.replace(":", "%3A").replace(",", "%2C") if title else text


label, paths = sys.argv[1], sys.argv[2:]
notices = []
for path in paths:
    chunks, current = [], ""
    for line in open(path, errors="replace").read().splitlines(keepends=True):
        line = line.encode()[: CHUNK // 2].decode(errors="ignore")
        if current and len(escape(current + line).encode()) > CHUNK:
            chunks.append(current)
            current = ""
        current += line
    chunks.append(current)
    for i, chunk in enumerate(chunks, 1):
        notices.append((f"{label} {os.path.basename(path)} ({i}/{len(chunks)})", chunk))
for title, body in notices[:LIMIT]:
    print(f"::notice title={escape(title, title=True)}::{escape(body)}")
if len(notices) > LIMIT:
    print(f"::warning::{len(notices) - LIMIT} result chunks didn't fit in annotations; see the artifact.")
