<!--
Template for a directory-scoped CLAUDE.md. Copy to <subdir>/CLAUDE.md and fill in.

Written and maintained by the orchestrator (see root CLAUDE.md §11).

Rules:
  - Additive. The root CLAUDE.md and .claude/AGENT_PROTOCOL.md still apply in full.
  - State ONLY what differs here. Delete every section you have nothing local to say in.
  - Keep the finished file under ~60 lines. It is read on every task in this subtree.
  - Never restate the graphify / skills / plan / git rules. They already apply.
  - Never put secrets, tokens, or real hostnames here. This file is committed.
  - Delete this comment block.
-->

# <subdir> — Local Instructions

**Scope:** everything under `<path/to/subdir>/`
**Owner role:** `<which agent owns this area — e.g. frontend-developer>`

## What this is

<One or two sentences. What lives here and what it is responsible for. Assume the reader
knows the project but has never opened this directory.>

## Commands

*Only the ones that differ from the root CLAUDE.md Commands table. Delete if identical.*

| Purpose | Command |
| --- | --- |
| Run (dev) | `<cmd>` |
| Test | `<cmd>` |
| Build | `<cmd>` |

## Local conventions

- `<naming, file layout, or patterns specific to this subtree>`
- `<the thing you keep having to re-explain about this directory>`

## Gotchas

- `<the non-obvious constraint that bites people — the reason this file exists>`

## Boundaries

- **Depends on:** `<what this subtree may import or call>`
- **Must not touch:** `<what is off-limits from here>`
- **Changes here require:** `<extra review, a migration, coordination with another area>`
