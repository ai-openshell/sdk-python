#!/usr/bin/env bash
# verify-tree.sh: check an extracted history against core at the freeze commit.
#
# Usage: verify-tree.sh <core-clone> <freeze-sha> <extracted-repo-or-ref>
#
# The expected tree comes from applying paths.txt to a single commit holding
# core's tree at <freeze-sha>, so the check reuses the extraction rules but
# none of the history. It then prints commit, author, and sign-off counts
# and fails on bare #N references left in commit messages.
set -euo pipefail

if [ $# -ne 3 ]; then
  echo "usage: $0 <core-clone> <freeze-sha> <extracted-repo>" >&2
  exit 2
fi

core=$1
freeze=$2
repo=$3
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
paths="$here/paths.txt"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

freeze=$(git -C "$core" rev-parse "${freeze}^{commit}")

# Expected tree: core's freeze tree in a one-commit repository, filtered with
# the same rules.
git init --quiet "$work/expected"
git -C "$core" archive "$freeze" | tar -x -C "$work/expected"
git -C "$work/expected" add -A
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$work/expected" -c user.name=verify -c user.email=verify@invalid \
  commit --quiet -m freeze
GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null \
  git -C "$work/expected" filter-repo --force --quiet --paths-from-file "$paths"
expected=$(git -C "$work/expected" rev-parse 'HEAD^{tree}')
actual=$(git -C "$repo" rev-parse 'HEAD^{tree}')

echo "expected tree: $expected"
echo "actual tree:   $actual"
echo "commits:       $(git -C "$repo" rev-list --count HEAD)"
echo "authors:       $(git -C "$repo" log --format='%an <%ae>' | sort -u | wc -l | tr -d ' ')"
echo "sign-offs:     $(git -C "$repo" log --format=%B | grep -c '^Signed-off-by:' || true)"
bare=$(git -C "$repo" log --format=%B | grep -cE '(^|[^A-Za-z0-9/#])#[0-9]+' || true)
echo "bare #N refs:  $bare"
echo "files:"
git -C "$repo" ls-tree -r --name-only HEAD | sed 's/^/  /'

[ "$expected" = "$actual" ] || {
  echo "FAIL: tree mismatch" >&2
  diff <(git -C "$work/expected" ls-tree -r HEAD) <(git -C "$repo" ls-tree -r HEAD) >&2 || true
  exit 1
}
[ "$bare" = 0 ] || {
  echo "FAIL: bare #N references remain" >&2
  exit 1
}
echo "OK"
