# Architecture

```text
Trellis specs/prds/research/reviews
                ↓
Pi execution prompts and agents
                ↓
mise root task contract
                ↓
manifest dispatcher → profile/module adapters
                ↓
uv / pnpm / Gradle Wrapper / CMake / Make / platform SDK
                ↓
Git branch + GitHub Actions verify gate
```

Trellis owns requirements and lifecycle. Pi owns repository-grounded execution. mise owns versions and task entry points. Native tools own dependency/build semantics. Git owns change isolation; CI owns the non-bypassable gate.
