#!/usr/bin/env bash
set -euo pipefail

COMMON_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="${TEMPLATE_ROOT:-$(cd "$COMMON_DIR/.." && pwd)}"
source "$TEMPLATE_ROOT/scripts/lib/logging.sh"
source "$TEMPLATE_ROOT/scripts/lib/profiles.sh"

profile_require_file() {
  [ -f "$1" ] || die "$PROFILE requires $1 in module $MODULE_NAME ($MODULE_PATH)"
}

profile_require_executable() {
  [ -x "$1" ] || die "$PROFILE requires executable $1 in module $MODULE_NAME ($MODULE_PATH)"
}

profile_skip() { log_info "$MODULE_NAME ($PROFILE): $1 SKIP${2:+ ($2)}"; }

profile_script_exists() {
  local script="$1"
  profile_run node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['$script'] ? 0 : 1)" >/dev/null 2>&1
}

profile_run_script() {
  local script="$1"
  shift
  profile_run pnpm run "$script" "$@"
}
