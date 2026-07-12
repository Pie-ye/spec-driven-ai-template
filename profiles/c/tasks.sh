#!/usr/bin/env bash
set -euo pipefail
TEMPLATE_ROOT="${TEMPLATE_ROOT:?TEMPLATE_ROOT is required}"
PROFILE="c"
source "$TEMPLATE_ROOT/profiles/cmake-tasks.sh"
