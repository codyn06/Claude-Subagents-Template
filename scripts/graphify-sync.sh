#!/usr/bin/env bash
# graphify-sync.sh — Stop / SubagentStop.
#
# "After modifying code, run `graphify update .`" — the recommended graphify practice,
# automated. Runs only when something was actually edited (marker file present) so a
# read-only turn costs nothing. AST-only: no API cost.
set -uo pipefail

ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MARKER="$ROOT/graphify-out/.needs_update"

[ -f "$MARKER" ] || exit 0
[ -f "$ROOT/graphify-out/graph.json" ] || exit 0

BIN="${GRAPHIFY_BIN:-}"
[ -n "$BIN" ] || BIN="$(command -v graphify 2>/dev/null || true)"
[ -n "$BIN" ] || exit 0

if (cd "$ROOT" && "$BIN" update . >/dev/null 2>&1); then
  rm -f "$MARKER" 2>/dev/null || true
fi

# Never block the Stop event.
exit 0
