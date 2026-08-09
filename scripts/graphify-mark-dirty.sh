#!/usr/bin/env bash
# graphify-mark-dirty.sh — PostToolUse(Edit|Write|MultiEdit|NotebookEdit).
#
# Marks the knowledge graph as stale instead of rebuilding on every keystroke.
# scripts/graphify-sync.sh drains the marker when the agent stops.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
[ -d "$ROOT/graphify-out" ] || exit 0

: > "$ROOT/graphify-out/.needs_update" 2>/dev/null || true
exit 0
