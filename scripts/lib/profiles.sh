#!/usr/bin/env bash
set -euo pipefail

PROFILE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_ROOT="${TEMPLATE_ROOT:-$(cd "$PROFILE_LIB_DIR/../.." && pwd)}"
PROFILE_MANIFEST="${PROFILE_MANIFEST:-$TEMPLATE_ROOT/.template/profiles.toml}"

profile_help() {
  cat <<'EOF'
Profile manifest helpers:
  enabled_profiles   Print enabled profile names, one per line.
  profile_entries    Print module|path|profile entries for dispatch.
  manifest_validate  Validate the explicit manifest and profile directories.
EOF
}

_toml_value() {
  local key="$1"
  awk -v key="$key" '
    $0 ~ "^[[:space:]]*" key "[[:space:]]*=" {
      line=$0
      sub(/^[^=]*=[[:space:]]*/, "", line)
      print line
      exit
    }
  ' "$PROFILE_MANIFEST"
}

enabled_profiles() {
  local value
  value="$(_toml_value enabled)"
  value="${value#\[}"
  value="${value%\]}"
  printf '%s\n' "$value" | tr ',' '\n' | sed -E 's/["[:space:]]//g' | sed '/^$/d'
}

profile_required_tasks() {
  local profile="$1"
  awk -v section="[profiles.${profile}]" '
    $0 == section { in_section=1; next }
    /^\[/ { in_section=0 }
    in_section && /^[[:space:]]*required_tasks[[:space:]]*=/ {
      line=$0; sub(/^[^=]*=[[:space:]]*/, "", line)
      gsub(/[\[\]",]/, " ", line)
      print line
      exit
    }
  ' "$PROFILE_MANIFEST" | tr ' ' '\n' | sed '/^$/d'
}

profile_entries() {
  local modules
  modules="$(awk '/^\[modules\.[^]]+\][[:space:]]*$/ { found=1 } END { if (found) print "yes" }' "$PROFILE_MANIFEST")"
  if [ "$modules" = "yes" ]; then
    awk '
      function emit() { if (module != "" && path != "" && profile != "") print module "|" path "|" profile }
      /^\[modules\.[^]]+\][[:space:]]*$/ {
        emit(); module=$0; sub(/^\[modules\./, "", module); sub(/\].*$/, "", module); path=""; profile=""; next
      }
      /^path[[:space:]]*=/ {
        line=$0; sub(/^[^=]*=[[:space:]]*/, "", line); gsub(/["[:space:]]/, "", line); path=line; next
      }
      /^profile[[:space:]]*=/ {
        line=$0; sub(/^[^=]*=[[:space:]]*/, "", line); gsub(/["[:space:]]/, "", line); profile=line; next
      }
      END { emit() }
    ' "$PROFILE_MANIFEST"
  else
    while IFS= read -r profile; do
      [ -n "$profile" ] && printf 'root|.|%s\n' "$profile"
    done < <(enabled_profiles)
  fi
}

profile_is_enabled() {
  local wanted="$1"
  enabled_profiles | grep -Fxq "$wanted"
}

profile_required() {
  local profile="$1" task="$2"
  profile_required_tasks "$profile" | grep -Fxq "$task"
}

profile_mise_file() {
  printf '%s/profiles/%s/mise.toml\n' "$TEMPLATE_ROOT" "$1"
}

profile_command_exists() {
  local command_name="$1"
  local active_profile="${PROFILE:-}"
  [ -n "$active_profile" ] || die "PROFILE is required for profile command checks"
  if command -v mise >/dev/null 2>&1 && [ -f "$(profile_mise_file "$active_profile")" ]; then
    mise -C "$(dirname "$(profile_mise_file "$active_profile")")" exec -- sh -c "command -v \"\$1\" >/dev/null 2>&1" sh "$command_name"
  else
    command -v "$command_name" >/dev/null 2>&1
  fi
}

profile_run() {
  local active_profile="${PROFILE:-}"
  [ -n "$active_profile" ] || die "PROFILE is required for profile commands"
  if command -v mise >/dev/null 2>&1 && [ -f "$(profile_mise_file "$active_profile")" ]; then
    local current_dir="$PWD"
    mise -C "$(dirname "$(profile_mise_file "$active_profile")")" exec -- sh -c "cd \"\$1\" && shift && exec \"\$@\"" sh "$current_dir" "$@"
  else
    "$@"
  fi
}

profile_install_tools() {
  local mise_file
  local active_profile="${PROFILE:-}"
  [ -n "$active_profile" ] || die "PROFILE is required for profile setup"
  mise_file="$(profile_mise_file "$active_profile")"
  [ -f "$mise_file" ] || die "Profile '$active_profile' is missing $mise_file"
  command -v mise >/dev/null 2>&1 || die "Profile '$active_profile' requires mise; install mise before setup"
  mise -C "$(dirname "$mise_file")" install
}

manifest_validate() {
  [ -f "$PROFILE_MANIFEST" ] || die "Missing profile manifest: $PROFILE_MANIFEST"
  grep -Eq '^[[:space:]]*enabled[[:space:]]*=' "$PROFILE_MANIFEST" || die "Manifest must define enabled = [...]"
  grep -Eq '^[[:space:]]*enabled[[:space:]]*=[[:space:]]*\[[^]]*\][[:space:]]*$' "$PROFILE_MANIFEST" || die "Manifest enabled list must be a closed TOML array"

  local profile
  while IFS= read -r profile; do
    [ -n "$profile" ] || continue
    [[ "$profile" =~ ^[a-z0-9-]+$ ]] || die "Invalid profile name: $profile"
    [ -d "$TEMPLATE_ROOT/profiles/$profile" ] || die "Enabled profile does not exist: $profile"
    [ -f "$TEMPLATE_ROOT/profiles/$profile/mise.toml" ] || die "Profile is missing mise.toml: $profile"
    [ -f "$TEMPLATE_ROOT/profiles/$profile/AGENTS.md" ] || die "Profile is missing AGENTS.md: $profile"
    [ -f "$TEMPLATE_ROOT/profiles/$profile/README.md" ] || die "Profile is missing README.md: $profile"
  done < <(enabled_profiles)

  local module path profile
  while IFS='|' read -r module path profile; do
    [ -n "${module:-}" ] || continue
    [[ "$path" != /* && "$path" != *".."* ]] || die "Module path must stay inside repository: $module=$path"
    [ -d "$TEMPLATE_ROOT/$path" ] || die "Module path does not exist: $module=$path"
    profile_is_enabled "$profile" || die "Module '$module' uses disabled profile '$profile'"
  done < <(profile_entries)
}

if [ "${1:-}" = "--help" ]; then profile_help; fi
