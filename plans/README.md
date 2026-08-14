# plans/

Plans written by the `planner` agent. **A plan here is binding on every agent that
implements it.**

- `TEMPLATE.md` — the structure every plan follows. Do not edit it per-project unless you
  are changing the process itself.
- `<slug>.spec.md` — the `product-manager`'s spec, when the request started as a goal.
- `<slug>.md` — the implementation plan. `<slug>` matches the git branch (`feat/<slug>`).

## Lifecycle

1. `planner` writes `plans/<slug>.md` with status `draft`.
2. The human (or the orchestrator on their behalf) approves it → status `approved`.
3. Implementation agents are dispatched **with the plan path** and implement only their
   assigned steps.
4. Deviations are reported and folded back into the plan.
5. Requirements changed? Re-dispatch `planner` to update the plan. Do not improvise.
6. When merged, set status `done`. Superseded plans get status `superseded` and a pointer
   to the plan that replaced them.

## Git policy

Plans are **tracked**. They are the record of *why* the code looks the way it does, and
`reviewer` reviews against them — a plan that is not in the repo at the reviewed
revision can be quietly edited to match whatever got built, which defeats the point.

Plans churn heavily while work is in flight. That churn does **not** belong in history.
A plan is committed at exactly two moments, both on the feature branch:

1. **On approval** — status `draft` → `approved`, before implementation starts:
   `docs(plan): approve <slug>`. This pins the target the auditor reviews against.
2. **With the work** — the plan's final state (status `done`, deviations folded in) rides
   the same branch as the code it produced and merges with it.

Everything between those two points is working-tree churn on the branch. `planner` and the
implementers never commit; only `release-manager` does, and it commits the plan at those
two moments and no others.

Consequences of this policy:

- A PR shows the plan and the code together, which is what a reviewer wants.
- Plan edits never land on a protected branch on their own.
- Superseded plans are marked `superseded` with a pointer to their replacement, not
  deleted — a deleted plan takes its rationale with it.
