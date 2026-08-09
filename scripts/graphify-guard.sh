#!/usr/bin/env bash
# graphify-guard.sh — portable wrapper around `graphify hook-guard`.
#
# Wired to PreToolUse so that Bash/Grep/Read/Glob calls are reminded to consult the
# knowledge graph first. Silently no-ops when graphify is not installed or no graph
# has been built, so the template stays portable across machines.
#
# Usage: graphify-guard.sh <search|read>
set -uo pipefail

MODE="${1:-search}"
ROOT="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# No graph → nothing to guard.
[ -f "$ROOT/graphify-out/graph.json" ] || exit 0

BIN="${GRAPHIFY_BIN:-}"
[ -n "$BIN" ] || BIN="$(command -v graphify 2>/dev/null || true)"
[ -n "$BIN" ] || exit 0

# stdin (the hook payload) is inherited by the child process.
"$BIN" hook-guard "$MODE"
rc=$?

# Pass through a deliberate block (exit 2); swallow anything else so a graphify
# failure can never wedge the session.
[ "$rc" -eq 2 ] && exit 2
exit 0
