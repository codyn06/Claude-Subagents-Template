#!/usr/bin/env bash
# scoped-context.sh — map the directory-scoped configuration tree.
#
# Lists every nested CLAUDE.md and .claude/ directory below the repo root, so the
# orchestrator knows which local rules exist before it edits anything in that subtree.
# Used by scripts/session-start.sh; safe to run by hand.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
cd "$ROOT" 2>/dev/null || exit 0

echo "## Directory-scoped configuration"
echo

# Candidate paths, respecting .gitignore when git is available.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  paths="$(git ls-files --cached --others --exclude-standard 2>/dev/null)"
else
  paths="$(find . -type f -not -path './.git/*' 2>/dev/null | sed 's|^\./||')"
fi

# A CLAUDE.md one level down that lives *inside* a .claude/ dir is part of that level's
# own config, not a directory-scoped file — exclude it.
nested_md="$(printf '%s\n' "$paths" | grep -E '^.+/CLAUDE\.md$' | grep -Ev '(^|/)\.claude/CLAUDE\.md$' | sort || true)"
nested_dirs="$(printf '%s\n' "$paths" | grep -E '^.+/\.claude/' | sed 's|/\.claude/.*|/.claude|' | sort -u || true)"

found=0

if [ -n "$nested_md" ]; then
  found=1
  while IFS= read -r f; do
    [ -n "$f" ] || continue
    title="$(sed -n 's/^#[[:space:]]*//p' "$f" 2>/dev/null | head -1)"
    lines="$(wc -l < "$f" 2>/dev/null | tr -d ' ')"
    printf -- '- %s — %s (%s lines)\n' "$f" "${title:-untitled}" "${lines:-?}"
  done <<< "$nested_md"
fi

if [ -n "$nested_dirs" ]; then
  found=1
  while IFS= read -r d; do
    [ -n "$d" ] || continue
    a=$(ls "$d/agents"/*.md 2>/dev/null | wc -l | tr -d ' ')
    s=$(ls -d "$d/skills"/*/ 2>/dev/null | wc -l | tr -d ' ')
    extra=""
    [ -f "$d/settings.json" ] && extra=" settings.json"
    printf -- '- %s/ — %s agent(s), %s skill(s)%s\n' "$d" "$a" "$s" "$extra"
  done <<< "$nested_dirs"
fi

if [ "$found" -eq 0 ]; then
  echo "None. The root CLAUDE.md and .claude/ apply everywhere in this repo."
else
  echo
  echo "Most specific wins: when working on a file, the nearest CLAUDE.md up the tree adds to"
  echo "(never replaces) the root one. Read it before editing in that subtree, and pass its"
  echo "path to any subagent you dispatch there. See CLAUDE.md §11."
fi

exit 0
