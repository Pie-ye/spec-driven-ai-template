#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"
source "$ROOT/scripts/lib/profiles.sh"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: ./scripts/setup.sh"
  echo "Install only tools declared by explicitly enabled profiles, then run profile setup tasks."
  exit 0
fi

manifest_validate
"$ROOT/scripts/run-task.sh" setup
log_info "setup passed"
