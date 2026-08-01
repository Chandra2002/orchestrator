---
description: One-time model setup for the Requirement-to-QA workflow. Asks for the scanning / design / coding models, validates each ID against `opencode models`, writes the role->model map into models.config.json, runs apply-models.sh to rewrite every agent file, and reminds the user to restart opencode. Run once per machine.
agent: build
---

You are running the one-time model setup for the Requirement-to-QA workflow kit.

Goal: configure which model each role uses and propagate that to every installed agent file. This is a CONFIG-TIME action — do it once per machine. The workflow orchestrator only validates afterwards and will never re-ask these questions.

Kit location defaults to `~/Desktop/opencode-workflow`. If the kit lives elsewhere, use that path. Agent install target defaults to `~/.config/opencode/agent`.

## Step 1 — Ask the 3 questions (use the question tool, one per role)
For each question, present the default as the first option with "(Recommended)". Let the user also type a custom ID. After each answer, VALIDATE it before moving on.

- **Scanning model** (used by `req-gathering`): "largest context, lowest cost". Recommended default: `opencode/deepseek-v4-flash-free`.
- **Design model** (used by `orchestrate`, `hld-designer`, `flows-identifier`, `test-generator`, `lld`, `spec-writer`): "strongest reasoning". Recommended default: `nvidia/nvidia/nemotron-3-ultra-550b-a55b`.
- **Coding model** (used by `implementation`, `scaffold`, `planner`, `implementer`, `integration`, `qa`, `dev`): "fast/cheap". Recommended default: `nvidia/openai/gpt-oss-20b`.

## Step 2 — Validate every answer
For each chosen ID:
1. Run `opencode models` (read-only) and capture the full list of available model IDs.
2. If the chosen ID is NOT in that list, tell the user which IDs were found, and RE-ASK that same question with the defaults still offered first. Repeat until the ID is found.
3. If `opencode models` fails to run, fall back to a format check (must match `<provider>/<model-id>`, no spaces) and warn the user that in-TUI validation may still reject it.

## Step 3 — Write models.config.json
Write (or overwrite) `<kit>/models.config.json` with EXACTLY this shape (preserve any `_notes` block you keep):

```json
{
  "roles": {
    "scanning": { "model": "<scanning-id>" },
    "design":   { "model": "<design-id>" },
    "coding":   { "model": "<coding-id>" }
  }
}
```

## Step 4 — Apply to agent files
Run:
`bash <kit>/scripts/apply-models.sh <kit>/models.config.json ~/.config/opencode/agent`

Verify the output shows a `SET <file> (<role>) -> <model>` line for ALL 14 agent files. If any file is SKIPPED for a missing role, fix that agent file's `options.model_role` and rerun.

## Step 5 — Tell the user
State clearly: **quit and restart opencode** — config is loaded at startup and not hot-reloaded, so the new models take effect only after a restart. Then confirm setup is complete and that changing models later is just a matter of rerunning `/setup`.
