# <Title> — Implementation Plan

- **Slug:** `<kebab-case-slug>` (also the branch name: `feat/<slug>`)
- **Author:** `planner`
- **Date:** `<YYYY-MM-DD>`
- **Status:** draft | approved | in progress | done | superseded
- **Spec:** `plans/<slug>.spec.md` (or "n/a")

## Problem

<What is wrong or missing, stated in one paragraph. Not the solution.>

## Context from the knowledge graph

<What `graphify query` / `path` / `explain` surfaced: the modules involved, the god nodes,
the community boundaries this change crosses. Cite source_location.>

## Approach

**Chosen:** <one paragraph, and why.>

**Rejected:**

| Option | Why not |
| --- | --- |
| <alternative> | <trade-off that ruled it out> |

## Files touched

| Path | Change |
| --- | --- |
| `<path>` | create / modify / delete — <what> |

## Steps

> Each step: one agent, one verifiable outcome. `[parallel]` marks steps with no ordering
> dependency on each other.

### Step 1 — <name>
- **Agent:** `<agent-name>`
- **Do:** <specific, unambiguous instruction>
- **Files:** `<paths>`
- **Verify:** `<command>` → <expected result>
- **Depends on:** none

### Step 2 — <name> `[parallel]`
- **Agent:** `<agent-name>`
- **Do:**
- **Files:**
- **Verify:**
- **Depends on:** Step 1

## Test strategy

- **Unit:** <what, by whom>
- **Integration:** <what>
- **End-to-end:** <what>
- **Regression:** <the failing test that must exist first, for bug fixes>

## Cross-cutting concerns

*Answer each. "None, because …" is acceptable; silence is not.*

- **Security:**
- **Performance:**
- **Accessibility:**
- **Data / migration:**
- **Documentation:**

## Risks

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| | | | |

## Rollback

<How to undo this if it goes wrong in production.>

## Definition of done

- [ ] Every step implemented and verified
- [ ] `<test command>` passes
- [ ] `<lint command>` and `<typecheck command>` clean
- [ ] `code-auditor` approved
- [ ] Review gate cleared (security / accessibility / performance as applicable)
- [ ] Docs and CHANGELOG updated
- [ ] `graphify update .` run

## Dispatch order

1. `<agent>` — Step 1
2. `<agent>` + `<agent>` — Steps 2, 3 **in parallel**
3. `code-auditor` — review gate
