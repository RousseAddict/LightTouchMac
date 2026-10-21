#!/bin/bash
# Turns a fresh upstream checkout into the Big Sur tree, in place, on a new branch of that checkout:
#   1. add      copy add/ into the tree (new packages and files; refuses to shadow an upstream file)
#   2. forks    copy forks/<path> over the upstream file, reporting drift from the upstream blob each fork mirrors
#   3. codemod  the mechanical rewrites (codemod.py)
#   4. patches  git apply --3way of patches/*.patch, in order
# Steps 1-3 are committed as one commit, then the patches as another, so `git diff HEAD~1` shows the hand patches and
# `git diff HEAD~2` the whole port. Use a checkout you can throw away (CI's, or a clone): it refuses a tree with
# changes, and leaves the upstream branch it started from as it was.
#
#   apply.sh UPSTREAM_CHECKOUT
set -euo pipefail
PORT=$(cd "$(dirname "$0")" && pwd)
SRC=$(cd "${1:?usage: apply.sh UPSTREAM_CHECKOUT}" && pwd)
die() { echo "apply.sh: $*" >&2; exit 1; }
commit() { git -C "$SRC" -c user.name="bigsur apply.sh" -c user.email="apply@bigsur.invalid" commit --quiet --no-verify "$@"; }

git -C "$SRC" rev-parse --git-dir > /dev/null 2>&1 || die "$SRC isn't a git -C "$SRC" checkout"
[ -z "$(git -C "$SRC" status --porcelain)" ] || die "$SRC has changes; apply.sh needs a fresh upstream checkout"
upstream=$(git -C "$SRC" rev-parse --short HEAD)
branch="bigsur-applied-$upstream"
if git -C "$SRC" rev-parse --verify --quiet "refs/heads/$branch" > /dev/null; then
    die "$SRC already has a $branch branch"
fi
git -C "$SRC" checkout --quiet -b "$branch"
echo "Applying the Big Sur port to $SRC ($upstream) on branch $branch"

echo "== 1. add"
if [ -d "$PORT/add" ]; then
    (cd "$PORT/add" && find . -type f) | sed 's|^\./||' | sort | while read -r rel; do
        if git -C "$SRC" ls-files --error-unmatch -- "$rel" > /dev/null 2>&1; then
            die "add/$rel would replace an upstream file"
        fi
        echo "  $rel"
    done
    rsync -a "$PORT/add/" "$SRC/"
fi

echo "== 2. forks"
drift=0
if [ -d "$PORT/forks" ]; then
    for fork in $(cd "$PORT/forks" && find . -type f ! -name '*.upstream-sha' | sed 's|^\./||' | sort); do
        [ -f "$SRC/$fork" ] || die "forks/$fork: upstream no longer has $fork"
        mirrored=$(cat "$PORT/forks/$fork.upstream-sha" 2> /dev/null || echo none)
        current=$(git -C "$SRC" rev-parse "HEAD:$fork")
        if [ "$mirrored" = "$current" ]; then
            echo "  $fork"
        else
            echo "  $fork  DRIFT: upstream blob $current, the fork mirrors $mirrored"
            drift=$((drift + 1))
        fi
        cp "$PORT/forks/$fork" "$SRC/$fork"
    done
fi

echo "== 3. codemod"
python3 -I "$PORT/codemod.py" "$SRC"
git -C "$SRC" add -A
commit -m "Big Sur port: add, forks and codemod (bigsur/apply.sh)"

echo "== 4. patches"
failed=""
threeway=""
for patch in "$PORT"/patches/*.patch; do
    [ -e "$patch" ] || continue
    if git -C "$SRC" apply --whitespace=nowarn "$patch" 2> /tmp/bigsur-apply.$$; then
        echo "  $(basename "$patch")"
    elif git -C "$SRC" apply --3way --whitespace=nowarn "$patch" 2> /tmp/bigsur-apply.$$; then
        # It needed upstream's earlier blob: a shallow checkout (the vendor and plan jobs') has none, and fails.
        echo "  $(basename "$patch")  3-WAY: regenerate it against this release, or a shallow checkout fails it"
        threeway="$threeway $(basename "$patch")"
    else
        echo "  $(basename "$patch")  FAILED"
        sed 's/^/      /' /tmp/bigsur-apply.$$
        failed="$failed $(basename "$patch")"
    fi
done
rm -f /tmp/bigsur-apply.$$
# A patch that failed may leave conflict markers: the tree stays uncommitted, to be looked at, not built.
[ -z "$failed" ] || die "patches that didn't apply:$failed (the tree is left uncommitted, conflicts and all)"
git -C "$SRC" add -A
if ! git -C "$SRC" diff --cached --quiet; then
    commit -m "Big Sur port: hand patches (bigsur/apply.sh)"
fi

[ "$drift" -eq 0 ] || echo "Forks with upstream drift: $drift (see above; the forks may need updating)"
[ -z "$threeway" ] || echo "Patches that needed a 3-way merge:$threeway (regenerate them against this release)"
echo "Done: $SRC is the Big Sur tree on $branch."
