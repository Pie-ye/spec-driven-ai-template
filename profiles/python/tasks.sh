#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_ROOT="${TEMPLATE_ROOT:?TEMPLATE_ROOT is required}"
source "$TEMPLATE_ROOT/profiles/_common.sh"

task="${1:-}"
if [ "$task" != clean ]; then profile_require_file pyproject.toml; fi

case "$task" in
doctor)
  profile_command_exists python || die "Python is unavailable for $MODULE_NAME"
  profile_command_exists uv || die "uv is unavailable for $MODULE_NAME"
  profile_run uv --version
  ;;
setup)
  profile_install_tools
  if [ -f uv.lock ]; then profile_run uv sync --locked; else profile_run uv sync; fi
  ;;
dev)
  profile_skip dev "define the application command in the module README"
  ;;
format)
  profile_run uv run ruff format .
  ;;
format-check)
  profile_run uv run ruff format --check .
  ;;
lint)
  profile_run uv run ruff check .
  ;;
typecheck)
  if grep -Eq '^\[tool\.(mypy|pyright)' pyproject.toml; then
    if grep -q '^\[tool\.mypy' pyproject.toml; then profile_run uv run mypy .; else profile_run uv run pyright; fi
  else
    profile_skip typecheck "no mypy/pyright configuration"
  fi
  ;;
test)
  profile_run uv run pytest -q
  ;;
build)
  if grep -q '^\[build-system\]' pyproject.toml; then profile_run uv build; else profile_skip build "no build-system configured"; fi
  ;;
verify)
  "$0" format-check
  "$0" lint
  "$0" typecheck
  "$0" test
  "$0" build
  ;;
clean)
  rm -rf .pytest_cache .ruff_cache .mypy_cache .pyright .venv build dist
  ;;
*) die "Unknown Python profile task: $task" ;;
esac
