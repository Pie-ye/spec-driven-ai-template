#!/usr/bin/env bash
set -euo pipefail

run_if_available() {
  local label="$1"
  shift
  if "$@"; then
    echo "[verify] ${label}: PASS"
  else
    echo "[verify] ${label}: FAIL" >&2
    return 1
  fi
}

run_pnpm_script_if_defined() {
  local script="$1"
  if node -e "const p=require('./package.json'); process.exit(p.scripts && p.scripts['${script}'] ? 0 : 1)"; then
    run_if_available "$script" pnpm "$script"
  else
    echo "[verify] ${script}: SKIP (not defined)"
  fi
}

echo "[verify] repository workflow checks"
test -f AGENTS.md
test -f PRD_EXECUTION.md
test -x ./.trellis/scripts/verify.sh || {
  echo "[verify] verify.sh must be executable" >&2
  exit 1
}
echo "[verify] workflow files: PASS"

if [ -f package.json ] && command -v pnpm >/dev/null 2>&1; then
  node -e "const p=require('./package.json'); if (!p) process.exit(1)"
  run_pnpm_script_if_defined "format:check"
  run_pnpm_script_if_defined "lint"
  run_pnpm_script_if_defined "typecheck"
  run_pnpm_script_if_defined "test"
  run_pnpm_script_if_defined "build"
elif [ -f package.json ]; then
  echo "[verify] package.json found but pnpm is unavailable; install the toolchain first" >&2
  exit 1
fi

if [ -f pyproject.toml ]; then
  command -v python3 >/dev/null 2>&1 || { echo "[verify] python3 is required" >&2; exit 1; }
  if python3 -m pytest --version >/dev/null 2>&1; then
    run_if_available "python tests" python3 -m pytest -q
  else
    echo "[verify] pyproject.toml found but pytest is unavailable" >&2
    exit 1
  fi
fi

if [ -f go.mod ]; then
  command -v go >/dev/null 2>&1 || { echo "[verify] go is required" >&2; exit 1; }
  run_if_available "go test" go test ./...
fi

echo "[verify] all configured checks passed"
