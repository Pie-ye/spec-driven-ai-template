# Polyglot product example

```toml
enabled = ["python", "web", "c"]

[modules.api]
path = "services/api"
profile = "python"

[modules.web]
path = "apps/web"
profile = "web"

[modules.native]
path = "libs/native"
profile = "c"
```

The root dispatcher labels each module and uses its native manifest. Add `AGENTS.md` inside each module for local rules.
