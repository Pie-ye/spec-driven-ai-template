#!/usr/bin/env bash
set -euo pipefail

task="${1:-unknown-task}"
action="${2:-unknown-action}"
status="${3:-ok}"
developer="${USER:-unknown-user}"
branch="$(git branch --show-current 2>/dev/null || printf 'unknown')"
log_dir=".trellis/workspace/${developer}"
mkdir -p "$log_dir"

python3 - "$log_dir/agent-log.jsonl" "$developer" "$branch" "$task" "$action" "$status" <<'PY'
import datetime, json, pathlib, sys
path, developer, branch, task, action, status = sys.argv[1:]
record = {
    "ts": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "user": developer,
    "branch": branch,
    "task": task,
    "action": action,
    "status": status,
}
pathlib.Path(path).open("a", encoding="utf-8").write(json.dumps(record, ensure_ascii=False) + "\n")
PY
echo "[agent-log] recorded ${action} (${status})"
