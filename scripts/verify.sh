#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"
source "$ROOT/scripts/lib/profiles.sh"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: ./scripts/verify.sh"
  echo "Run core script checks and every enabled profile's verify task."
  exit 0
fi

manifest_validate
log_info "core files: PASS"

while IFS= read -r script; do
  bash -n "$script"
done < <(find "$ROOT/scripts" "$ROOT/profiles" -type f -name '*.sh' -print 2>/dev/null | sort)
log_info "shell syntax: PASS"

if command -v shellcheck >/dev/null 2>&1; then
  shell_files=()
  while IFS= read -r shell_file; do shell_files+=("$shell_file"); done < <(find "$ROOT/scripts" "$ROOT/profiles" -type f -name '*.sh' -print | sort)
  shellcheck -x "${shell_files[@]}"
  log_info "shellcheck: PASS"
else
  log_info "shellcheck: SKIP (not installed; CI may provide it)"
fi

if command -v node >/dev/null 2>&1; then
  node "$ROOT/scripts/orchestrator.mjs" self-test
else
  log_info "orchestrator self-test: SKIP (Pi's Node runtime unavailable)"
fi

"$ROOT/tests/test-scripts.sh"
"$ROOT/scripts/run-task.sh" verify
log_info "all configured verification passed"
