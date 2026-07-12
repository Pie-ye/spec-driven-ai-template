#!/usr/bin/env bash
set -euo pipefail

log_info() { printf '[%s] %s\n' "${LOG_SCOPE:-template}" "$*"; }
log_warn() { printf '[%s] WARNING: %s\n' "${LOG_SCOPE:-template}" "$*" >&2; }
log_error() { printf '[%s] ERROR: %s\n' "${LOG_SCOPE:-template}" "$*" >&2; }
die() {
  log_error "$*"
  exit 1
}
