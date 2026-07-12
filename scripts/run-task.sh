#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"
source "$ROOT/scripts/lib/profiles.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/run-task.sh <task>

Tasks: doctor setup dev format format-check lint typecheck test build verify clean
EOF
}

TASK="${1:-}"
[ -n "$TASK" ] || {
  usage
  exit 2
}
case "$TASK" in
doctor | setup | dev | format | format-check | lint | typecheck | test | build | verify | clean) ;;
-h | --help)
  usage
  exit 0
  ;;
*) die "Unknown task '$TASK'. Use --help for supported tasks." ;;
esac

manifest_validate
entries="$(profile_entries)"
if [ -z "$entries" ]; then
  log_info "No profiles enabled; task '$TASK' is a no-op"
  exit 0
fi

failed=0
while IFS='|' read -r module module_path profile; do
  [ -n "${module:-}" ] || continue
  task_script="$ROOT/profiles/$profile/tasks.sh"
  if [ ! -x "$task_script" ]; then
    if profile_required "$profile" "$TASK"; then
      log_error "$profile/$TASK is required but $task_script is missing"
      failed=1
    else
      log_info "$module ($profile): $TASK SKIP (adapter missing)"
    fi
    continue
  fi

  log_info "$module ($profile): $TASK"
  if ! (
    export TEMPLATE_ROOT="$ROOT"
    export PROFILE_MANIFEST="$ROOT/.template/profiles.toml"
    export MODULE_NAME="$module"
    export MODULE_PATH="$module_path"
    export PROFILE="$profile"
    cd "$ROOT/$module_path"
    "$task_script" "$TASK"
  ); then
    log_error "$module ($profile): $TASK FAIL"
    failed=1
  fi
done <<<"$entries"

exit "$failed"
