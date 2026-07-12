#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/scripts/lib/logging.sh"

usage() {
  cat <<'EOF'
Usage: ./scripts/finish-prd.sh PRD-ID

Validate the PRD branch, run `mise run verify`, check the evidence table,
and write a review summary. This script never merges main.
EOF
}

if [ "${1:-}" = "-h" ] || [ "${1:-}" = "--help" ]; then
  usage
  exit 0
fi
[ "$#" -eq 1 ] || {
  usage
  exit 2
}
id="$1"
prd=""
shopt -s nullglob
candidates=("$ROOT/.trellis/prds/${id}-"*.md)
shopt -u nullglob
for candidate in "${candidates[@]}"; do
  if [ -f "$candidate" ]; then
    prd="$candidate"
    break
  fi
done
[ -n "$prd" ] || die "No canonical PRD found for $id"

branch="$(git -C "$ROOT" branch --show-current)"
slug="$(basename "$prd" .md | sed "s/^${id}-//")"
expected="prd/${id}-${slug}"
[ "$branch" = "$expected" ] || die "Expected branch '$expected', found '$branch'"

log_info "working tree status:"
git -C "$ROOT" status --short
command -v mise >/dev/null 2>&1 || die "mise is required; install it before running finish-prd"
mise -C "$ROOT" run verify

if grep -Eq '^\|[[:space:]]*AC-[0-9]+[[:space:]]*\|[[:space:]]*(Pending|Unclear|Fail)' "$prd"; then
  die "PRD evidence table still contains Pending, Unclear, or Fail entries: ${prd#"$ROOT"/}"
fi

review="$ROOT/.trellis/reviews/${id}-summary.md"
[ ! -e "$review" ] || die "Review summary already exists: ${review#"$ROOT"/}"
mkdir -p "$(dirname "$review")"
cat >"$review" <<EOF
# Review summary: $id

- Branch: \`$branch\`
- PRD: \`${prd#"$ROOT"/}\`
- Verification: \`mise run verify\` passed
- Working tree at finish: see command output above
- Merge action: not performed by policy

Independent reviewer must now inspect the final diff and write a verdict using \`.trellis/reviews/REVIEW-TEMPLATE.md\`.
EOF
log_info "review summary: ${review#"$ROOT"/}"
log_info "READY_FOR_INDEPENDENT_REVIEW; main was not merged"
