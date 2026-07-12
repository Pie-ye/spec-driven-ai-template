#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_ROOT="${TEMPLATE_ROOT:?TEMPLATE_ROOT is required}"
source "$TEMPLATE_ROOT/profiles/_common.sh"

task="${1:-}"
if [ "$task" != clean ]; then profile_require_file CMakeLists.txt; fi

build_dir="${CMAKE_BUILD_DIR:-build}"
configure() {
  profile_command_exists cmake || die "CMake is unavailable for $MODULE_NAME"
  if [ -f CMakePresets.json ]; then
    preset="${CMAKE_PRESET:-dev}"
    if profile_run cmake --list-presets 2>/dev/null | grep -Fq "\"$preset\""; then
      profile_run cmake --preset "$preset"
    else
      die "CMake preset '$preset' is not defined; choose CMAKE_PRESET from cmake --list-presets"
    fi
  else
    profile_run cmake -S . -B "$build_dir" -G Ninja
  fi
}

qt_doctor() {
  if profile_command_exists qtpaths || profile_command_exists qmake || [ -n "${Qt6_DIR:-}${Qt5_DIR:-}${QT_HOST_PATH:-}" ]; then
    log_info "Qt SDK: detected or explicitly configured"
  else
    die "Qt SDK not detected; install it with the platform-appropriate method or set Qt6_DIR/QT_HOST_PATH"
  fi
}

case "$task" in
doctor)
  profile_command_exists cmake || die "CMake is unavailable for $MODULE_NAME"
  profile_command_exists ninja || die "Ninja is unavailable for $MODULE_NAME"
  [ "$PROFILE" != "qt-cpp" ] || qt_doctor
  profile_run cmake --version
  ;;
setup)
  profile_install_tools
  [ "$PROFILE" != "qt-cpp" ] || qt_doctor
  configure
  ;;
dev)
  profile_skip dev "run the module's documented executable or Qt target"
  ;;
format | format-check)
  if ! profile_command_exists clang-format; then
    profile_skip "$task" "clang-format unavailable"
    exit 0
  fi
  sources=()
  while IFS= read -r source_file; do sources+=("$source_file"); done < <(git ls-files '*.c' '*.cc' '*.cpp' '*.h' '*.hh' '*.hpp' '*.hxx')
  [ "${#sources[@]}" -gt 0 ] || {
    profile_skip "$task" "no C/C++ sources"
    exit 0
  }
  if [ "$task" = format ]; then
    profile_run clang-format -i "${sources[@]}"
  else
    profile_run clang-format --dry-run --Werror "${sources[@]}"
  fi
  ;;
lint)
  if [ -f compile_commands.json ] && profile_command_exists clang-tidy; then
    sources=()
    while IFS= read -r source_file; do sources+=("$source_file"); done < <(git ls-files '*.cc' '*.cpp')
    [ "${#sources[@]}" -gt 0 ] && profile_run clang-tidy -p . "${sources[@]}"
  elif profile_command_exists cppcheck; then
    profile_run cppcheck --enable=warning,style,performance,portability --error-exitcode=1 --quiet .
  else
    profile_skip lint "clang-tidy/cppcheck unavailable or compile_commands.json missing"
  fi
  ;;
typecheck)
  profile_skip typecheck "CMake compiler checks run during configure/build"
  ;;
test)
  [ -d "$build_dir" ] || configure
  profile_run ctest --test-dir "$build_dir" --output-on-failure
  ;;
build)
  [ -d "$build_dir" ] || configure
  profile_run cmake --build "$build_dir" --parallel
  ;;
verify)
  "$0" format-check
  "$0" lint
  "$0" typecheck
  "$0" build
  "$0" test
  ;;
clean)
  rm -rf "$build_dir"
  ;;
*) die "Unknown CMake profile task: $task" ;;
esac
