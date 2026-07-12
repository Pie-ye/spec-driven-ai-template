#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/profiles.sh"

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  echo "Usage: ./scripts/list-profiles.sh"
  exit 0
fi

manifest_validate
printf '%-12s %-8s %s\n' PROFILE ENABLED DESCRIPTION
for profile_dir in "$ROOT"/profiles/*; do
  [ -d "$profile_dir" ] || continue
  profile="$(basename "$profile_dir")"
  enabled=No
  profile_is_enabled "$profile" && enabled=Yes
  description="$(awk 'NF && $0 !~ /^#/ { print; exit }' "$profile_dir/README.md")"
  printf '%-12s %-8s %s\n' "$profile" "$enabled" "$description"
done
