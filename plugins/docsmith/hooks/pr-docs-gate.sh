#!/bin/sh
# Blocks the first `gh pr create` on each branch so the agent decides on docs
# and the changelog before the PR exists. The retry on the same branch passes.
grep -q 'gh pr create' || exit 0

git_dir=$(git rev-parse --git-dir 2>/dev/null) || exit 0
branch=$(git rev-parse --abbrev-ref HEAD | tr '/' '_')
marker="$git_dir/docsmith-pr-checked-$branch"
[ -e "$marker" ] && exit 0
touch "$marker"

cat >&2 <<'MSG'
docsmith: before opening this PR, run the docsmith:document-change skill for
this branch (all commits since the base branch). Update the docs that own the
changed behavior and add a changelog entry only if the change is significant.
Commit any doc changes, then run the same `gh pr create` again; it will pass.
If nothing needs documenting, say so in one line and retry.
MSG
exit 2
