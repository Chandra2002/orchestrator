#!/usr/bin/env bash
set -euo pipefail

KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG="${1:-$KIT_DIR/models.config.json}"
TARGET="${2:-$HOME/.config/opencode/agent}"

if [ ! -f "$CONFIG" ]; then
  echo "Config not found: $CONFIG" >&2
  exit 1
fi
if [ ! -d "$TARGET" ]; then
  echo "Target dir not found: $TARGET" >&2
  echo "Run the install copy first (see README) or pass a target dir." >&2
  exit 1
fi

echo "== apply-models =="
echo "config : $CONFIG"
echo "target : $TARGET"
echo

python3 - "$CONFIG" "$TARGET" <<'PY'
import json, os, re, sys

cfg_path, target = sys.argv[1], sys.argv[2]
roles = json.load(open(cfg_path))["roles"]

def frontmatter(txt):
    m = re.search(r"^---\n(.*?)\n---", txt, re.S)
    return (m.group(1), txt[m.end():]) if m else (None, txt)

def role_of(fm):
    m = re.search(r"^\s*model_role:\s*(\S+)", fm, re.M)
    return m.group(1) if m else None

count = 0
for root, dirs, files in os.walk(target):
    for fn in files:
        if not fn.endswith(".md"):
            continue
        path = os.path.join(root, fn)
        txt = open(path).read()
        fm, body = frontmatter(txt)
        if fm is None:
            print(f"SKIP (no frontmatter): {path}")
            continue
        role = role_of(fm)
        if role is None:
            print(f"SKIP (no options.model_role): {path}")
            continue
        if role not in roles:
            print(f"SKIP (unknown role '{role}'): {path}")
            continue
        model = roles[role]["model"]
        new_fm = re.sub(r"(?m)^model:\s*\S.*$", f"model: {model}", fm)
        if new_fm == fm:
            print(f"SKIP (unchanged): {fn} ({role}) -> {model}")
            continue
        open(path, "w").write("---\n" + new_fm + "\n---" + body)
        print(f"SET {fn} ({role}) -> {model}")
        count += 1

print()
print(f"Done. {count} file(s) updated. Restart opencode to pick up changes.")
PY
