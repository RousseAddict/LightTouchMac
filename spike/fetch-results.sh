#!/bin/bash
# Fetches the ci-results branch and prints a run's summaries per job; the full error lists and logs stay in the
# branch (git show REMOTE/ci-results:RUN_ID/JOB/errors-NAME.txt). Runs on the Big Sur Mac, with no GitHub login.
#
#   fetch-results.sh RUN_ID [REMOTE]
set -euo pipefail
RUN=${1:?usage: fetch-results.sh RUN_ID [REMOTE]}
REMOTE=${2:-fork}
git fetch --quiet "$REMOTE" ci-results
for job in $(git ls-tree --name-only "$REMOTE/ci-results:$RUN"); do
    echo "######## $job"
    for file in $(git ls-tree --name-only "$REMOTE/ci-results:$RUN/$job" | grep '^summary-'); do
        git show "$REMOTE/ci-results:$RUN/$job/$file"
        echo
    done
done
