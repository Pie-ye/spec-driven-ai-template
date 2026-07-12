#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root"

if [ "${SKIP_SYSTEM_PACKAGES:-0}" = "1" ]; then
  echo "[bootstrap] skipping system packages (SKIP_SYSTEM_PACKAGES=1)"
else
  case "$(uname -s)" in
  Linux)
    if [ -f /etc/os-release ]; then
      . /etc/os-release
      case "${ID:-}" in
      ubuntu | debian) exec "$repo_root/ops/bootstrap/ubuntu.sh" ;;
      arch) exec "$repo_root/ops/bootstrap/arch.sh" ;;
      fedora) exec "$repo_root/ops/bootstrap/fedora.sh" ;;
      esac
    fi
    ;;
  *) echo "[bootstrap] OS package setup is documented for Linux; continuing" ;;
  esac
fi

if ! command -v mise >/dev/null 2>&1; then
  echo "[bootstrap] mise is not installed; install mise before running mise run setup"
fi

if command -v pi >/dev/null 2>&1; then
  echo "[bootstrap] Pi detected; project-local packages are declared in .pi/settings.json"
else
  echo "[bootstrap] Pi is not installed. Install @earendil-works/pi-coding-agent when needed."
fi

echo "[bootstrap] repository ready: $repo_root"
