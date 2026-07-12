# Qt/C++ Profile Rules

- `CMakeLists.txt` and `CMakePresets.json` are build sources of truth.
- Do not edit generated moc/uic/rcc output.
- Preserve QObject ownership, signal/slot, thread-affinity, and UI-thread rules.
- Qt SDK and compiler/ABI are platform-specific; use `doctor` to report missing SDKs.
- Prefer clang-format, clang-tidy, CTest, and existing project test conventions.
