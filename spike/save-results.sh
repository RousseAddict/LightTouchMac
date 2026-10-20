#!/bin/bash
# Commits this job's results to the ci-results branch: the probe, the summaries, every distinct error line and the
# compressed build logs, under RUN_ID/JOB/. Logs and artifacts need a signed-in account even on a public
# repository; a branch can be fetched with any clone. Jobs that finish together rebase and retry.
#
#   save-results.sh   (env: OUT, RUN_ID, JOB, GH_TOKEN, GITHUB_REPOSITORY; CI_RESULTS_REMOTE overrides the remote, for tests)
set -euo pipefail
: "${OUT:?}" "${RUN_ID:?}" "${JOB:?}" "${GH_TOKEN:?}" "${GITHUB_REPOSITORY:?}"
REMOTE=${CI_RESULTS_REMOTE:-"https://x-access-token:$GH_TOKEN@github.com/$GITHUB_REPOSITORY.git"}
DEST="$RUNNER_TEMP/ci-results"

if ! git clone --quiet --depth 1 --branch ci-results "$REMOTE" "$DEST" 2>/dev/null; then
    git init --quiet "$DEST"
    git -C "$DEST" checkout --quiet --orphan ci-results
    git -C "$DEST" remote add origin "$REMOTE"
fi
DIR="$DEST/$RUN_ID/$JOB"
mkdir -p "$DIR"
cp "$OUT"/probe.txt "$OUT"/summary-*.md "$DIR/" 2>/dev/null || true
for log in "$OUT"/*.log; do
    [ -e "$log" ] || continue
    name=$(basename "$log" .log)
    grep -E 'error:|is only available in macOS' "$log" | grep -v 'lstat(' | sort -u > "$DIR/errors-$name.txt" || true
    gzip -9 -c "$log" > "$DIR/$name.log.gz"
done

git -C "$DEST" add -A
git -C "$DEST" -c user.name="spike" -c user.email="spike@users.noreply.github.com" \
    commit --quiet -m "Results: run $RUN_ID, $JOB"
for attempt in 1 2 3 4 5; do
    git -C "$DEST" push --quiet origin HEAD:ci-results 2>/dev/null && { echo "Saved to ci-results:$RUN_ID/$JOB"; exit 0; }
    sleep $((attempt * 3))
    git -C "$DEST" pull --quiet --rebase origin ci-results
done
echo "::warning::Couldn't push the results to ci-results"
