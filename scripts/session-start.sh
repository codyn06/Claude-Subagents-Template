#!/usr/bin/env bash
# session-start.sh — SessionStart. Everything printed here is injected into the
# orchestrator's context: the skill inventory, graph status, and open plans.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

echo "# Session bootstrap (scripts/session-start.sh)"
echo
echo "You are the **orchestrator**. Your operating manual is CLAUDE.md; the shared rules"
echo "every subagent follows are in .claude/AGENT_PROTOCOL.md. Delegate implementation to"
echo "the agents in .claude/agents/ rather than doing it inline."
echo

# --- knowledge graph ---------------------------------------------------------
echo "## Knowledge graph"
echo
if [ -f "$ROOT/graphify-out/graph.json" ]; then
  echo "graphify-out/graph.json exists. Answer codebase questions with"
  echo '`graphify query "<question>"` / `graphify path "<A>" "<B>"` / `graphify explain "<concept>"`'
  echo "BEFORE Grep/Glob/bulk Read. Pass this rule into every subagent prompt."
  [ -f "$ROOT/graphify-out/wiki/index.md" ] && echo "Wiki index available: graphify-out/wiki/index.md (use for broad navigation)."
  [ -f "$ROOT/graphify-out/.needs_update" ] && echo "STALE: code changed since the last build — run \`graphify update .\`."
else
  echo "No graph yet. Run \`/graphify .\` once to build it, then keep it fresh with"
  echo "\`graphify update .\` (AST-only, no API cost)."
fi
echo

# --- plans -------------------------------------------------------------------
echo "## Plans"
echo
plan_list=""
if [ -d "$ROOT/plans" ]; then
  for p in "$ROOT/plans"/*.md; do
    [ -f "$p" ] || continue
    base="$(basename "$p")"
    case "$base" in README.md|TEMPLATE.md) continue ;; esac
    title="$(sed -n 's/^#[[:space:]]*//p' "$p" 2>/dev/null | head -1)"
    plan_list="${plan_list}- plans/${base} — ${title:-untitled}
"
  done
fi

if [ -n "$plan_list" ]; then
  printf '%s\n' "$plan_list"
  echo "Implementation agents must be handed the plan path and must follow it."
else
  echo "No plans yet. Non-trivial work goes through the \`planner\` agent first;"
  echo "its plan lands in plans/<slug>.md and is binding on every implementer."
fi
echo

# --- git ---------------------------------------------------------------------
branch="$(cd "$ROOT" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
if [ -n "$branch" ]; then
  echo "## Git"
  echo
  echo "Current branch: \`$branch\`"
  case "$branch" in
    main|master|develop|release/*)
      echo "This is a protected branch — scripts/git-guard.sh blocks commits and pushes here."
      echo "Start feature work with \`git switch -c feat/<slug>\`."
      ;;
  esac
  echo
fi

# --- skills ------------------------------------------------------------------
if [ -f "$ROOT/scripts/skills-inventory.sh" ]; then
  bash "$ROOT/scripts/skills-inventory.sh"
fi

exit 0
