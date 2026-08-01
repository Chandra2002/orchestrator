# Requirement-to-QA Workflow Kit

A multi-agent opencode workflow that takes a requirement and drives it through gathering, HLD, flow identification, test generation, implementation, integration, QA and bug-fixing — with human review at the right gates, a shared knowledgebase that carries context between phases, and resume/checkpointing so long runs survive restarts.

## Contents

```
opencode-workflow/
├── README.md                  <- this file
├── orchestrate.md             <- MASTER orchestrator (primary agent) — start here
├── models.config.json         <- role-based model map (scanning/design/coding)
├── agents/                    <- 13 subagents (install location below)
│   ├── req-gathering.md       <- phase 1: requirements + scope + stack decision
│   ├── hld-designer.md        <- phase 2: HLD block diagrams (HTML)
│   ├── flows-identifier.md    <- phase 3: flows + per-flow scope
│   ├── test-generator.md      <- phase 4: sanity + regression cases
│   ├── implementation.md      <- phase 5 orchestrator (spawns the five below)
│   ├── scaffold.md            <- greenfield repo skeleton (per configured stack)
│   ├── lld.md                 <- LLD sequence diagrams (sequential, reviewed)
│   ├── spec-writer.md         <- specs per configured stack (sequential, reviewed)
│   ├── planner.md             <- implementation plans (parallel, no review)
│   ├── implementer.md         <- code + tests in isolated git worktrees (parallel)
│   ├── integration.md         <- phase 6: merge, wire, build, deploy, push, runbook
│   ├── qa.md                  <- phase 7: implement + run sanity/regression
│   └── dev.md                 <- phase 8: fix QA failures, re-trigger QA
├── templates/
│   └── knowledgebase-template.md  <- 12-section append-only KB schema
├── commands/
│   └── setup.md               <- one-time interactive model setup (/setup)
└── scripts/
    ├── scaffold.sh            <- optional pre-flight helper
    └── apply-models.sh        <- rewrites agent model: lines from models.config.json
```

## Install (one-time)

opencode loads agents and commands from your global config directory. Copy the agent files, the orchestrator, and the setup command there:

```sh
mkdir -p ~/.config/opencode/agent ~/.config/opencode/command
cp ~/Desktop/opencode-workflow/agents/*.md ~/Desktop/opencode-workflow/orchestrate.md ~/.config/opencode/agent/
cp ~/Desktop/opencode-workflow/commands/setup.md ~/.config/opencode/command/
```

Then **quit and restart opencode** — config is loaded at startup and not hot-reloaded.

## Configure models (one-time, per machine)

Run `/setup` in opencode once per machine. It asks three interactive questions (scanning / design / coding), validates each model ID against `opencode models` (re-asks if not found), writes `models.config.json`, runs `apply-models.sh` to rewrite every agent file, and tells you to restart.

`models.config.json` is the **single source of truth** for models. It is role-based (not per-agent):

| Role      | Default model               | Agents that use it                                                   | Best fit                                  |
|-----------|-----------------------------|----------------------------------------------------------------------|-------------------------------------------|
| `scanning`| `anthropic/claude-sonnet-4` | req-gathering                                                        | 1M-context, low-cost model                |
| `design`  | `anthropic/claude-opus-4`   | orchestrate, hld-designer, flows-identifier, test-generator, lld, spec-writer | strongest reasoning model       |
| `coding`  | `anthropic/claude-sonnet-4` | implementation, scaffold, planner, implementer, integration, qa, dev  | fast/cheap model                          |

To change a model:
1. Edit the `roles.<role>.model` value in `models.config.json`.
2. Run `bash ~/Desktop/opencode-workflow/scripts/apply-models.sh` (rewrites the `model:` line in every installed agent file). You can point it at a different config or target dir: `apply-models.sh [config.json] [target-dir]`.
3. Restart opencode.

Each agent file also carries `options.model_role` so the file is self-documenting; that field is not the effective config — the `model:` line is, and `apply-models.sh` keeps it in sync (it reads the role from each file, so the JSON holds only role → model). The orchestrator validates the map exists with all three roles populated and spot-checks a couple of agent files at the start of every run — it never re-asks the setup questions.

Note: model IDs are provider-prefixed (`<provider>/<model-id>`). Defaults in `models.config.json` are verified against `opencode models`; change them via `/setup` if your machine's available models differ.

## Run the workflow

1. Start opencode and switch to the **orchestrate** agent.
2. It asks you to name the requirement folder (checks only that folder for a `workflow.state.json` resume file), then asks you for the requirement name (creates `~/Desktop/<requirement-name>/`), validates the model map, and asks whether this is greenfield or an existing repo (plus reference paths/URLs).
3. **The tech stack is decided during requirement gathering** — the req-gathering agent asks you for backend/frontend/build/test and the orchestrator stores it in `workflow.config.json`. Nothing is hardcoded.
4. Approve at each review gate as they appear: HLD, flow list, per-flow scope, test inputs/outputs, LLD, Spec.
5. Fill the `.env` when Integration asks (DB, Redis, broker, etc.).
6. Decide exclusions during the QA loop if tests fail.

## How the knowledgebase propagates

- Scaffold creates `~/Desktop/<requirement-name>/knowledgebase.md` from the template (12 sections, append-only).
- Each phase copies the current KB into its own subfolder (`ReqGateAgent/`, `HLDAgent/`, ...), updates only its sections, and passes its path back to the orchestrator.
- The orchestrator **verifies each returned KB path differs from the input** (catches "forgot to copy") and **syncs the root KB after every gate**, not just at the end.
- Sections are fixed; agents may only append to their own sections, never delete another's.

## Resume / checkpointing

After every phase the orchestrator writes `~/Desktop/<requirement-name>/workflow.state.json` (`nextPhase`, `currentKBPath`, `artifactPaths`, `qaRounds`). On startup it asks you to name the requirement folder and checks only that folder for the state file, offering to resume from where the run stopped instead of restarting from Step 0.

## Branch & git model

- **Greenfield:** `scaffold` creates the repo skeleton per the configured stack, leaves a clean `master`, and writes the resolved repo path back into `workflow.config.json.repoPath`.
- **Implementer:** each flow works in an **isolated git worktree** (`<runtime>/worktrees/<flow-id>`, branch `feature/<flow-id>` from master) — parallel implementers never race the same clone. Commit + rebase, no push.
- **Integration:** `feature/integration` from master, merges all flow branches, wires cross-flow calls, builds, deploys locally, persists `runbook.md`, sanity-checks, then commit → rebase → push.
- **Dev** fixes on `feature/integration`, rebase, push, re-trigger QA.
- Rebase command everywhere: `git fetch origin master && git rebase origin/master`.

## Startup runbook (QA/Dev reuse)

Integration persists `<runtime>/IntegrationAgent/runbook.md`: exact startup/shutdown commands, `.env` layout, ports, health endpoints, and test invocation. QA and Dev MUST follow it instead of re-deriving how to boot the services.

## Pre-approved permissions

Scanning-heavy agents pre-approve `git *`, `rg *`, plus native `read`/`glob`/`grep`/`list`, and external-directory reads so scanning never prompts you. Build agents pre-approve `mvn`/`npm`/`git`/`docker` etc. The orchestrator may only `rm` inside the runtime folder. Everything else still asks. Review the `permission:` blocks in each agent file and tighten if you prefer.

## Optional helper

```sh
bash ~/Desktop/opencode-workflow/scripts/scaffold.sh
```

Prompts for the requirement name, creates the runtime folder + subfolders + empty KB, copies `models.config.json`, and asks for the repo path — saving a ready `workflow.config.json`. The orchestrator can do all of this itself; the script is a convenience.
