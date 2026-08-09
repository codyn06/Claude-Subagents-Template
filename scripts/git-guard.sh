#!/usr/bin/env bash
# git-guard.sh — PreToolUse(Bash). Enforces the git practices in .claude/AGENT_PROTOCOL.md.
#
# Blocks (exit 2, reason goes back to the model):
#   - commits / pushes straight onto a protected branch
#   - --no-verify / --no-gpg-sign (hook and signature bypass)
#   - force pushes without --force-with-lease, and any force push to a protected branch
#   - destructive history or worktree operations (reset --hard, clean -fd, filter-branch, …)
#   - global git config mutation
#
# Escape hatch for the rare legitimate case, set by the human, not by the agent:
#   GIT_GUARD=off              disable entirely
#   ALLOW_PROTECTED_BRANCH=1   allow commits/pushes on a protected branch
set -uo pipefail

[ "${GIT_GUARD:-on}" = "off" ] && exit 0

PROTECTED_RE='^(main|master|develop|release(/.*)?)$'
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

payload="$(cat 2>/dev/null || true)"

# Pull tool_input.command out of the hook payload; fall back to the raw payload so the
# guard still works without a JSON parser available.
cmd=""
for py in python3 python py; do
  if command -v "$py" >/dev/null 2>&1; then
    cmd="$(printf '%s' "$payload" | "$py" -c 'import sys,json
try:
    d = json.load(sys.stdin)
except Exception:
    sys.exit(0)
print((d.get("tool_input") or {}).get("command", ""))' 2>/dev/null)"
    break
  fi
done
[ -n "$cmd" ] || cmd="$payload"

# Blank out quoted strings before flag matching, so a commit *message* mentioning
# "--no-verify" or "-n" is not mistaken for the flag itself.
cmd="$(printf '%s' "$cmd" | sed 's/"[^"]*"/""/g; s/'"'"'[^'"'"']*'"'"'/'"''"'/g')"

# Not a git command → nothing to do.
printf '%s' "$cmd" | grep -Eq '(^|[;&|(]|[[:space:]])git[[:space:]]' || exit 0

has() { printf '%s' "$cmd" | grep -Eq -- "$1"; }

deny() {
  printf 'BLOCKED by scripts/git-guard.sh\n\n%s\n\nSee .claude/AGENT_PROTOCOL.md §4 (Git discipline).\n' "$1" >&2
  exit 2
}

branch="$(cd "$ROOT" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"

# --- hook / signature bypass -------------------------------------------------
has '--no-verify' &&
  deny "--no-verify skips the hooks that keep this repo honest.
Fix what the hook is complaining about instead of bypassing it."

# `git commit -n` is --no-verify's shorthand. Look for it only in the flags belonging to
# the commit itself, not in a later command on the same line.
if has '(^|[[:space:]])git[[:space:]]+commit([[:space:]]|$)'; then
  commit_flags="$(printf '%s' "$cmd" | sed -n 's/.*git[[:space:]]\{1,\}commit//p')"
  commit_flags="${commit_flags%%&&*}"; commit_flags="${commit_flags%%;*}"; commit_flags="${commit_flags%%|*}"
  printf '%s' "$commit_flags" | grep -Eq '(^|[[:space:]])-[a-zA-Z]*n([[:space:]]|$)' &&
    deny "'git commit -n' is --no-verify. Do not skip the hooks — fix what they flag."
fi

has '--no-gpg-sign' &&
  deny "Do not bypass commit signing. If signing is broken, report it — do not disable it."

# --- force pushes ------------------------------------------------------------
if has '(^|[[:space:]])git[[:space:]]+push' && has '(--force([[:space:]]|$)|[[:space:]]-f([[:space:]]|$))'; then
  deny "Bare force push. Use 'git push --force-with-lease' so you cannot clobber
commits someone else pushed while you were working."
fi

if has '(^|[[:space:]])git[[:space:]]+push' && has '--force-with-lease' &&
   printf '%s' "$cmd" | grep -Eq '(main|master|develop)([[:space:]]|$|:)'; then
  deny "Force push targeting a protected branch. Protected history is never rewritten —
open a PR, or a revert commit if something must be undone."
fi

# --- destructive worktree / history ------------------------------------------
has '(^|[[:space:]])git[[:space:]]+reset[[:space:]].*--hard' &&
  deny "'git reset --hard' throws away uncommitted work irreversibly.
Use 'git stash' if you need a clean tree, or ask the human first."

has '(^|[[:space:]])git[[:space:]]+clean[[:space:]]+-[a-zA-Z]*f' &&
  deny "'git clean -f' permanently deletes untracked files, including files the human
may not have committed yet. Ask before running it."

has '(^|[[:space:]])git[[:space:]]+(filter-branch|filter-repo)' &&
  deny "History rewriting is a human decision, not an agent one."

has '(^|[[:space:]])git[[:space:]]+reflog[[:space:]]+expire|(^|[[:space:]])git[[:space:]]+gc[[:space:]].*--prune' &&
  deny "This destroys the reflog — the last safety net for recovering lost commits."

has '(^|[[:space:]])git[[:space:]]+push[[:space:]].*(--mirror|--delete|[[:space:]]:[A-Za-z0-9._/-]+)' &&
  deny "Deleting or mirroring remote refs is destructive and outward-facing.
Ask the human to do it."

has '(^|[[:space:]])git[[:space:]]+branch[[:space:]]+-D([[:space:]]|$)' &&
  deny "'git branch -D' force-deletes unmerged work. Use '-d', or ask first."

has '(^|[[:space:]])git[[:space:]]+update-ref[[:space:]]+-d' &&
  deny "Direct ref deletion bypasses every safety net git has."

has '(^|[[:space:]])git[[:space:]]+config[[:space:]].*--global' &&
  deny "Do not mutate the human's global git config. Scope changes to this repo, or ask."

# --- protected branch --------------------------------------------------------
if [ "${ALLOW_PROTECTED_BRANCH:-0}" != "1" ] && printf '%s' "$branch" | grep -Eq "$PROTECTED_RE"; then
  if has '(^|[[:space:]])git[[:space:]]+(commit|merge)([[:space:]]|$)' && ! has '--dry-run'; then
    deny "You are on '$branch'. Feature work never lands directly on a protected branch.

  git switch -c feat/<slug>     # or fix/, chore/, docs/

then commit there and open a PR."
  fi
  if has '(^|[[:space:]])git[[:space:]]+push([[:space:]]|$)' && ! has '--dry-run'; then
    deny "You are on '$branch'. Push a feature branch and open a PR instead of pushing
to a protected branch."
  fi
fi

exit 0
