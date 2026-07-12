#!/usr/bin/env bash
set -euo pipefail
TEMPLATE_ROOT="${TEMPLATE_ROOT:?TEMPLATE_ROOT is required}"
PROFILE="qt-cpp"
source "$TEMPLATE_ROOT/profiles/cmake-tasks.sh"
