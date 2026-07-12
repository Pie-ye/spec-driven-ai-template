#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_ROOT="${TEMPLATE_ROOT:?TEMPLATE_ROOT is required}"
source "$TEMPLATE_ROOT/profiles/_common.sh"

task="${1:-}"
if [ "$task" != clean ]; then profile_require_executable ./gradlew; fi

gradle_has_task() { profile_run ./gradlew --no-daemon --quiet tasks --all | grep -Eq "^[[:space:]]*$1([[:space:]]|$)"; }

case "$task" in
doctor)
  profile_command_exists java || die "JDK is unavailable for $MODULE_NAME"
  profile_run java -version
  ;;
setup)
  profile_install_tools
  profile_run ./gradlew --no-daemon --version
  ;;
dev)
  profile_skip dev "run the module's documented application task"
  ;;
format)
  if gradle_has_task spotlessApply; then profile_run ./gradlew --no-daemon spotlessApply; elif gradle_has_task ktlintFormat; then profile_run ./gradlew --no-daemon ktlintFormat; else profile_skip format "no Spotless or ktlint format task"; fi
  ;;
format-check)
  if gradle_has_task spotlessCheck; then profile_run ./gradlew --no-daemon spotlessCheck; elif gradle_has_task ktlintCheck; then profile_run ./gradlew --no-daemon ktlintCheck; else profile_skip format-check "no Spotless or ktlint check task"; fi
  ;;
lint)
  if gradle_has_task detekt; then profile_run ./gradlew --no-daemon detekt; elif gradle_has_task lint; then profile_run ./gradlew --no-daemon lint; else profile_skip lint "no detekt or lint task"; fi
  ;;
typecheck)
  profile_skip typecheck "Gradle compile tasks provide Kotlin type checking"
  ;;
test)
  profile_run ./gradlew --no-daemon test
  ;;
build)
  profile_run ./gradlew --no-daemon build
  ;;
verify)
  "$0" format-check
  "$0" lint
  "$0" typecheck
  "$0" test
  "$0" build
  ;;
clean)
  profile_run ./gradlew --no-daemon clean
  ;;
*) die "Unknown Kotlin profile task: $task" ;;
esac
