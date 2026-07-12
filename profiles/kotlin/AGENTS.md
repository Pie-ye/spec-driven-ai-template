# Kotlin Profile Rules

- Always use the repository Gradle Wrapper (`./gradlew` or `gradlew.bat`).
- `build.gradle.kts`, version catalogs, and the wrapper are dependency/toolchain sources of truth.
- Do not install or invoke a global Gradle binary.
- Preserve coroutine, lifecycle, Android, and test conventions already used by the module.
