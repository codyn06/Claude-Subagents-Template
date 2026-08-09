#!/usr/bin/env bash
# context-inject.sh — UserPromptSubmit. A short, always-visible reminder of the three
# rules that are easiest to forget mid-session. Keep this output tiny.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
line=""

[ -f "$ROOT/graphify-out/graph.json" ] &&
  line="${line}graphify first (\`graphify query\`) before Grep/Glob/bulk Read. "

[ -f "$ROOT/graphify-out/.needs_update" ] &&
  line="${line}Graph is STALE — \`graphify update .\`. "

if [ -d "$ROOT/plans" ]; then
  n="$(ls "$ROOT/plans"/*.md 2>/dev/null | grep -Evc '/(README|TEMPLATE)\.md$' || true)"
  [ "${n:-0}" -gt 0 ] 2>/dev/null &&
    line="${line}${n} plan(s) in plans/ — hand the plan path to every implementation agent. "
fi

branch="$(cd "$ROOT" 2>/dev/null && git rev-parse --abbrev-ref HEAD 2>/dev/null || true)"
case "$branch" in
  main|master|develop|release/*) line="${line}On protected branch '$branch' — branch before you commit." ;;
esac

[ -n "$line" ] && echo "[orchestrator reminder] $line"
exit 0
