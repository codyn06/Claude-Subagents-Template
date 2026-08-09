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

Plans are committed. They are the record of *why* the code looks the way it does, and
`code-auditor` reviews against them.
