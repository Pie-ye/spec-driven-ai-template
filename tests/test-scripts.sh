#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"

tmp="$(mktemp -d "${TMPDIR:-/tmp}/template-tests.XXXXXX")"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/scripts/lib" "$tmp/tests"
cp "$ROOT/.template/profiles.toml" "$tmp/.template-profiles.toml"
mkdir -p "$tmp/.template"
mv "$tmp/.template-profiles.toml" "$tmp/.template/profiles.toml"
cp -R "$ROOT/profiles" "$tmp/profiles"
cp "$ROOT/scripts/lib"/*.sh "$tmp/scripts/lib/"
cp "$ROOT/scripts/run-task.sh" "$ROOT/scripts/enable-profile.sh" "$ROOT/scripts/list-profiles.sh" "$ROOT/scripts/verify.sh" "$tmp/scripts/"

TEMPLATE_ROOT="$tmp" "$tmp/scripts/run-task.sh" verify >/dev/null

TEMPLATE_ROOT="$tmp" "$tmp/scripts/enable-profile.sh" python >/dev/null
TEMPLATE_ROOT="$tmp" "$tmp/scripts/enable-profile.sh" python >/dev/null
count="$(grep '^enabled' "$tmp/.template/profiles.toml" | grep -o '"python"' | wc -l | tr -d ' ')"
[ "$count" -eq 1 ] || die "profile enablement is not idempotent"

if TEMPLATE_ROOT="$tmp" "$tmp/scripts/enable-profile.sh" does-not-exist >/dev/null 2>&1; then
  die "unknown profile unexpectedly enabled"
fi

TEMPLATE_ROOT="$tmp" "$tmp/scripts/enable-profile.sh" web >/dev/null
mkdir -p "$tmp/services/backend" "$tmp/apps/frontend"
cat >>"$tmp/.template/profiles.toml" <<'EOF'

[modules.backend]
path = "services/backend"
profile = "python"

[modules.frontend]
path = "apps/frontend"
profile = "web"
EOF
TEMPLATE_ROOT="$tmp" "$tmp/scripts/run-task.sh" clean >"$tmp/multi-profile.log"
grep -q 'backend (python)' "$tmp/multi-profile.log"
grep -q 'frontend (web)' "$tmp/multi-profile.log"

cp "$tmp/.template/profiles.toml" "$tmp/valid-manifest.toml"
sed -i 's/^enabled =.*/enabled = [/' "$tmp/.template/profiles.toml"
if TEMPLATE_ROOT="$tmp" "$tmp/scripts/run-task.sh" verify >/dev/null 2>&1; then
  die "malformed manifest unexpectedly passed"
fi
mv "$tmp/valid-manifest.toml" "$tmp/.template/profiles.toml"

rm "$tmp/profiles/python/tasks.sh"
if TEMPLATE_ROOT="$tmp" "$tmp/scripts/run-task.sh" verify >/dev/null 2>&1; then
  die "missing required task adapter unexpectedly passed"
fi

log_info "script harness: PASS"
