#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"
source "$ROOT/scripts/lib/profiles.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/enable-profile.sh <profile>

Enable one existing profile in .template/profiles.toml. The operation is idempotent
and only changes the enabled list; it never overwrites project files or module rules.
EOF
}

PROFILE_NAME="${1:-}"
if [ "$PROFILE_NAME" = "-h" ] || [ "$PROFILE_NAME" = "--help" ]; then
  usage
  exit 0
fi
[ -n "$PROFILE_NAME" ] || {
  usage
  exit 2
}
[[ "$PROFILE_NAME" =~ ^[a-z0-9-]+$ ]] || die "Invalid profile name: $PROFILE_NAME"
[ -d "$ROOT/profiles/$PROFILE_NAME" ] || die "Unknown profile '$PROFILE_NAME'. Run ./scripts/list-profiles.sh."

manifest_validate
if profile_is_enabled "$PROFILE_NAME"; then
  log_info "profile already enabled: $PROFILE_NAME"
  exit 0
fi

tmp="$(mktemp "${TMPDIR:-/tmp}/profiles.XXXXXX")"
trap 'rm -f "$tmp"' EXIT
awk -v profile="$PROFILE_NAME" '
  BEGIN { added=0 }
  /^[[:space:]]*enabled[[:space:]]*=/ {
    line=$0
    value=line
    sub(/^[^=]*=[[:space:]]*/, "", value)
    sub(/^\[/, "", value)
    sub(/\].*$/, "", value)
    gsub(/["[:space:]]/, "", value)
    if (value == "") value="\"" profile "\""
    else value="\"" value "\", \"" profile "\""
    print "enabled = [" value "]"
    added=1
    next
  }
  { print }
  END { if (!added) exit 2 }
' "$PROFILE_MANIFEST" >"$tmp" || die "Could not update enabled profile list"
mv "$tmp" "$PROFILE_MANIFEST"
manifest_validate
log_info "enabled profile: $PROFILE_NAME"
log_info "next: inspect profiles/$PROFILE_NAME/README.md, then run mise run setup"
