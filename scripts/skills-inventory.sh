#!/usr/bin/env bash
# skills-inventory.sh — enumerate every skill available to this project.
#
# Used by:
#   - scripts/session-start.sh   (injected into the orchestrator's context)
#   - every subagent             (step 1 of .claude/AGENT_PROTOCOL.md)
#
# Prints one line per skill: "- <name> (<scope>) — <description>"
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
HOME_DIR="${HOME:-${USERPROFILE:-}}"

frontmatter_field() {
  # $1 = SKILL.md path, $2 = field name. Takes the first match, strips quotes.
  sed -n "s/^$2:[[:space:]]*//p" "$1" 2>/dev/null | head -1 | tr -d '"' | tr -d "\r"
}

emit_skills() {
  local dir="$1" scope="$2"
  [ -d "$dir" ] || return 0
  for skill in "$dir"/*/SKILL.md; do
    [ -f "$skill" ] || continue

    local name desc
    name="$(frontmatter_field "$skill" name)"
    [ -n "$name" ] || name="$(basename "$(dirname "$skill")")"
    desc="$(frontmatter_field "$skill" description | cut -c1-180)"
    printf -- '- %s (%s) — %s\n' "$name" "$scope" "${desc:-no description}"
  done
  return 0
}

echo "## Skills available in this project"
echo
echo "Invoke with the Skill tool. If any of these plausibly applies to the task, use it."
echo

emit_skills "$ROOT/.claude/skills" "project"
[ -n "$HOME_DIR" ] && emit_skills "$HOME_DIR/.claude/skills" "user"

echo
echo "Plugin/marketplace skills (superpowers, vercel, anthropic-skills, …) are listed in"
echo "your available-skills context block and are invoked the same way."
