# Claude Subagents Template

A drop-in Claude Code configuration modeled on a normal software organization: a planning
layer, an implementation layer, and a review gate — plus the hooks that keep skills,
the knowledge graph, and git discipline enforced rather than merely suggested.

## What you get

```
CLAUDE.md                    orchestrator definition + project description TEMPLATE
.claude/
  AGENT_PROTOCOL.md          rules binding on every subagent
  CLAUDE.md                  skill pointer
  settings.json              hook wiring
  agents/                    16 role definitions
  skills/graphify/           vendored skill
plans/
  TEMPLATE.md                the plan structure planner writes to
  README.md                  plan lifecycle
scripts/                     hook scripts (bash; Git Bash on Windows)
```

## Setup

1. Copy this repo (or use it as a GitHub template).
2. **Fill in section 1 of `CLAUDE.md`** — name, stack, layout, and especially the
   **Commands** table. Agents verify their work with those commands; wrong entries mean
   unverified results.
3. Build the knowledge graph once:
   ```bash
   graphify .
   ```
4. Start Claude Code. The `SessionStart` hook reports the skill inventory, graph status,
   open plans, and current branch.

## The roles

| Layer | Agents |
| --- | --- |
| Product | `product-manager` |
| Planning | `planner` *(highest model — the only one)* |
| Design | `ux-designer` |
| Implementation | `frontend-developer`, `api-developer`, `database-manager`, `devops-engineer` |
| Quality | `qa-engineer`, `product-tester`, `code-auditor` |
| Security | `cybersecurity-engineer`, `penetration-tester` |
| Non-functional | `performance-engineer`, `accessibility-manager` |
| Delivery | `technical-writer`, `release-manager` |

Thinking is centralized: `planner` runs on the highest available model and produces a
binding plan; everyone else executes it on `sonnet`. See `CLAUDE.md` §3 for the pipeline
and §4 for the routing table.

## What the hooks enforce

| Hook | Script | Effect |
| --- | --- | --- |
| `SessionStart` | `session-start.sh` | Injects skills, graph status, open plans, branch |
| `UserPromptSubmit` | `context-inject.sh` | One-line standing reminder |
| `PreToolUse` (Bash, Grep, Read, Glob) | `graphify-guard.sh` | Graph before grep |
| `PreToolUse` (Bash) | `git-guard.sh` | Blocks unsafe git |
| `PostToolUse` (edits) | `graphify-mark-dirty.sh` | Marks the graph stale |
| `Stop`, `SubagentStop` | `graphify-sync.sh` | Runs `graphify update .` when stale |

Every hook fails open — a missing `graphify` binary or a script error never wedges a
session.

`git-guard.sh` blocks commits and pushes on `main`/`master`/`develop`/`release/*`,
`--no-verify`, `--no-gpg-sign`, bare force pushes, `reset --hard`, `clean -f`,
`filter-branch`, reflog expiry, remote-ref deletion, `branch -D`, and `--global` config
changes. Escape hatches, for humans not agents:

```bash
ALLOW_PROTECTED_BRANCH=1 git commit -m "chore: bootstrap"
```

```bash
GIT_GUARD=off git <anything>
```

## Requirements

- Claude Code
- `bash` on `PATH` (Git Bash on Windows)
- `graphify` on `PATH`, or `GRAPHIFY_BIN` pointing at it — optional; hooks no-op without it
- `python3`/`python` — optional; `git-guard.sh` degrades to raw payload matching without it

## Customizing

- **Add a role:** drop a file in `.claude/agents/`, point it at
  `.claude/AGENT_PROTOCOL.md`, and add a row to `CLAUDE.md` §4.
- **Change shared rules:** edit `.claude/AGENT_PROTOCOL.md` once — every agent references
  it rather than restating it.
- **Change the pipeline:** edit `CLAUDE.md` §3.
- **Machine-local overrides:** `.claude/settings.local.json` (gitignored).
