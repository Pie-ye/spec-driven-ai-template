# Python Profile Rules

- `pyproject.toml` and `uv.lock` are dependency sources of truth.
- Use `uv sync` and `uv run`; do not install project dependencies with global pip.
- Keep Ruff, pytest, and the selected type checker configured in the project.
- Do not commit `.venv`, build output, or secrets.
- Preserve async, typing, and framework conventions already present in the module.
