#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_ROOT="${TEMPLATE_ROOT:?TEMPLATE_ROOT is required}"
source "$TEMPLATE_ROOT/profiles/_common.sh"

task="${1:-}"
if [ "$task" != clean ]; then profile_require_file package.json; fi

case "$task" in
doctor)
  profile_command_exists node || die "Node is unavailable for $MODULE_NAME"
  profile_command_exists pnpm || die "pnpm is unavailable for $MODULE_NAME"
  profile_run node --version
  profile_run pnpm --version
  ;;
setup)
  profile_install_tools
  if [ -f pnpm-lock.yaml ]; then profile_run pnpm install --frozen-lockfile; else profile_run pnpm install; fi
  ;;
dev)
  if profile_script_exists dev; then profile_run_script dev; else profile_skip dev "no package.json dev script"; fi
  ;;
format)
  if profile_script_exists format; then profile_run_script format; else profile_skip format "no package.json format script"; fi
  ;;
format-check)
  if profile_script_exists format:check; then profile_run_script format:check; else profile_skip format-check "no package.json format:check script"; fi
  ;;
lint)
  if profile_script_exists lint; then profile_run_script lint; else profile_skip lint "no package.json lint script"; fi
  ;;
typecheck)
  if profile_script_exists typecheck; then profile_run_script typecheck; else profile_skip typecheck "no package.json typecheck script"; fi
  ;;
test)
  if profile_script_exists test; then profile_run_script test; else profile_skip test "no package.json test script"; fi
  ;;
build)
  if profile_script_exists build; then profile_run_script build; else profile_skip build "no package.json build script"; fi
  ;;
verify)
  "$0" format-check
  "$0" lint
  "$0" typecheck
  "$0" test
  "$0" build
  ;;
clean)
  rm -rf node_modules dist build coverage .next .turbo
  ;;
*) die "Unknown Web profile task: $task" ;;
esac
