#!/usr/bin/env bash
set -euo pipefail

root=".trellis/tasks"
found=0
while IFS= read -r file; do
  found=1
  python3 - "$file" <<'PY'
import json, pathlib, sys
path = pathlib.Path(sys.argv[1])
try:
    data = json.loads(path.read_text(encoding="utf-8"))
except Exception as exc:
    print(f"{path.parent.name}: INVALID ({exc})")
    raise SystemExit
print(f"{path.parent.name}: {data.get('status', 'unknown')} | {data.get('title', data.get('name', 'untitled'))}")
PY
done < <(find "$root" -mindepth 2 -maxdepth 2 -name task.json -type f -print | sort)

if [ "$found" -eq 0 ]; then
  echo "No task.json files found. Create one from .trellis/templates/."
fi
