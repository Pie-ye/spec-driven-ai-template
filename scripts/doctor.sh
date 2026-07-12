#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"
source "$ROOT/scripts/lib/profiles.sh"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  cat <<'EOF'
Usage: ./scripts/doctor.sh

Validate the explicit profile manifest and run each enabled profile's doctor task.
File detection only prints suggestions; it never changes the manifest.
EOF
  exit 0
fi

manifest_validate
log_info "manifest: $PROFILE_MANIFEST"
enabled="$(enabled_profiles | paste -sd, -)"
log_info "enabled profiles: ${enabled:-none}"

suggestions=()
[ -f pyproject.toml ] && suggestions+=(python)
[ -f package.json ] && suggestions+=(web)
if [ -f gradlew ] || [ -f build.gradle.kts ]; then suggestions+=(kotlin); fi
[ -f CMakeLists.txt ] && suggestions+=(c)
if [ "${#suggestions[@]}" -gt 0 ]; then
  log_info "detected files suggest (not enabled): ${suggestions[*]}"
fi

"$ROOT/scripts/run-task.sh" doctor
log_info "doctor passed"
