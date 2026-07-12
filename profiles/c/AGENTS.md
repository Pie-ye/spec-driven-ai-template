# C Profile Rules

- `CMakeLists.txt`, Makefiles, and toolchain files remain build sources of truth.
- Do not assume a compiler ABI; document GCC/Clang and sanitizer requirements in the module.
- Keep headers, ownership, error returns, and public ABI changes explicit.
- Use static analysis and sanitizers when configured by the project.
