#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "== Requirement-to-QA Workflow: pre-flight scaffold =="
echo

# 1. Requirement folder name
read -r -p "Requirement name (used for the Desktop folder): " REQ_NAME
REQ_NAME="${REQ_NAME//[^a-zA-Z0-9_-]/_}"
if [ -z "$REQ_NAME" ]; then
  echo "Requirement name cannot be empty." >&2
  exit 1
fi

RUNTIME_DIR="$HOME/Desktop/$REQ_NAME"
mkdir -p "$RUNTIME_DIR"

# 2. Subfolders
for SUB in ReqGateAgent HLDAgent FlowsIdentifierAgent TestGeneratorAgent ImplementationAgent IntegrationAgent QAAgent DevAgent; do
  mkdir -p "$RUNTIME_DIR/$SUB"
done

# 3. Root knowledgebase from template
if [ ! -f "$RUNTIME_DIR/knowledgebase.md" ]; then
  sed "s/<requirement-name>/$REQ_NAME/g" "$KIT_DIR/templates/knowledgebase-template.md" > "$RUNTIME_DIR/knowledgebase.md"
  echo "Created $RUNTIME_DIR/knowledgebase.md"
fi

# 4. Models config (defaults) — user should review/edit, then run apply-models.sh
if [ ! -f "$RUNTIME_DIR/models.config.json" ]; then
  cp "$KIT_DIR/models.config.json" "$RUNTIME_DIR/models.config.json"
  echo "Copied models.config.json (role defaults) -> $RUNTIME_DIR/models.config.json"
  echo "  >> Edit the roles map in that file, then run:"
  echo "     bash $KIT_DIR/scripts/apply-models.sh $RUNTIME_DIR/models.config.json ~/.config/opencode/agent"
fi

# 5. Repo type + path
REPO=""
GREENFIELD=""
read -r -p "Greenfield (repo created fresh; stack decided during requirement gathering) or existing repo? [g/e] " GT
if [ "$GT" = "g" ] || [ "$GT" = "G" ]; then
  GREENFIELD="true"
else
  GREENFIELD="false"
  read -r -p "Existing repo path: " REPO
fi

# 6. workflow.config.json
# Note: stack is intentionally null here — it is decided by the user
# during requirement gathering (req-gathering phase) and filled in by the orchestrator.
cat > "$RUNTIME_DIR/workflow.config.json" <<EOF
{
  "requirementName": "$REQ_NAME",
  "runtimeFolder": "$RUNTIME_DIR",
  "greenfield": $GREENFIELD,
  "repoPath": "$REPO",
  "references": [],
  "stack": null
}
EOF

echo
echo "== Done =="
echo "Runtime folder : $RUNTIME_DIR"
echo "Next           : open opencode, switch to the 'orchestrate' agent, and tell it to start."
echo "                 (Or run it directly from this folder; it reads workflow.config.json)."
