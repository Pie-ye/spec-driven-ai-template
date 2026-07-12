#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/create-prd-branch.sh PRD-ID slug

Create prd/<PRD-ID>-<slug> from the latest local main. If origin exists,
update main with fast-forward-only; no reset, deletion, or force operation is used.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi
[ "$#" -eq 2 ] || {
  usage
  exit 2
}
id="$1"
slug="$2"
[[ "$id" =~ ^PRD-[0-9]+$ ]] || die "PRD ID must look like PRD-001"
[[ "$slug" =~ ^[a-z0-9-]+$ ]] || die "Slug must contain lowercase letters, numbers, and hyphens"

git -C "$ROOT" rev-parse --show-toplevel >/dev/null 2>&1 || die "Not a Git repository: $ROOT"
[ -z "$(git -C "$ROOT" status --porcelain)" ] || die "Working tree is not clean; commit or stash changes first"

current="$(git -C "$ROOT" branch --show-current)"
if [ "$current" != "main" ]; then git -C "$ROOT" switch main; fi

if git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  git -C "$ROOT" fetch origin main
  git -C "$ROOT" pull --ff-only origin main
else
  log_warn "No origin remote; using local main"
fi

branch="prd/${id}-${slug}"
if git -C "$ROOT" show-ref --verify --quiet "refs/heads/$branch"; then
  die "Branch already exists: $branch"
fi
git -C "$ROOT" switch -c "$branch"

prd="$ROOT/.trellis/prds/${id}-${slug}.md"
if [ ! -f "$prd" ]; then
  [ -f "$ROOT/.trellis/prds/TEMPLATE.md" ] || die "Missing .trellis/prds/TEMPLATE.md"
  cp "$ROOT/.trellis/prds/TEMPLATE.md" "$prd"
  sed -i.bak -e "s/PRD-XXX/${id}/g" -e "s/Title/${slug}/g" "$prd"
  rm -f "$prd.bak"
fi
log_info "branch: $branch"
log_info "PRD: ${prd#"$ROOT"/}"
