# Getting started

## 1. Install core tools

Install Git, Bash, mise, and a compiler/SDK only when the selected Profile requires it. From this template root run `mise install`; the root configuration contains only shellcheck and shfmt.

## 2. Select capabilities

Run `./scripts/list-profiles.sh`, then `./scripts/enable-profile.sh <profile>`. For a monorepo, edit `.template/profiles.toml` and add `[modules.<name>]` entries. Re-running enablement is safe and idempotent.

## 3. Create project records

Copy `.trellis/specs/TEMPLATE.md` for product context, then `.trellis/prds/TEMPLATE.md` for an executable PRD. Acceptance criteria must be observable and include an evidence row.

## 4. Implement one PRD

Use `./scripts/create-prd-branch.sh PRD-001 slug`, read `.pi/prompts/execute-prd.md`, and keep one primary writing agent on the branch.

## 5. Verify and review

Run `mise run doctor`, `mise run setup`, and `mise run verify`. Fill the evidence table, run `./scripts/finish-prd.sh PRD-001`, then request independent review and open a PR.
