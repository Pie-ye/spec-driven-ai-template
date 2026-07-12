# Spec-Driven AI Development Template

這是一套可移植的 Trellis + Pi + GitHub 開發流程模板，適合以 PRD 驅動 AI 輔助開發，並可在 Ubuntu、Arch、Fedora、WSL2 或遠端 Linux 主機重建環境。

## 核心規則

- 一份 PRD 對應一個 branch。
- 同一時間只執行一份 PRD。
- `.trellis/spec/`、`.trellis/tasks/` 與 `.trellis/workspace/` 是可提交的流程記錄。
- Pi 是執行引擎；PRD 與驗收條件才是工作範圍的來源。
- 完成前必須執行 `./.trellis/scripts/verify.sh`，並保留命令證據。
- 未經明確指示，不自動 merge `main`，不把 secrets 提交進 repo。

## 快速開始

```bash
git clone https://github.com/YOUR_ORG/spec-driven-ai-template.git my-project
cd my-project
./.trellis/scripts/bootstrap.sh
cp .trellis/templates/prd.template.md .trellis/tasks/PRD-001-example.md
./.trellis/scripts/verify.sh
```

若已安裝 mise，可直接使用：

```bash
mise install
mise run verify
```

啟動 Pi 後，先信任專案，再使用 `/skill:execute-prd` 或 `/skill:review-prd`。Pi 套件版本已固定在 `.pi/settings.json`；不需要把 `~/.pi/agent/auth.json` 放進 repo。

## 開發循環

```text
spec → PRD → prd/<id>-<slug> branch → plan → implement → verify → review → PR
```

建立任務分支：

```bash
git switch main
git pull --ff-only
git switch -c prd/PRD-001-example
```

工作完成後，執行 `./.trellis/scripts/verify.sh`，檢查 `git diff`，再推送 branch 建立 Pull Request。GitHub Actions 會執行跨平台驗證；正式部署由各專案在此模板上增加 application-specific workflow。

## 在其他主機部署流程環境

Linux：

```bash
git clone https://github.com/YOUR_ORG/spec-driven-ai-template.git ~/code/my-project
cd ~/code/my-project
./.trellis/scripts/bootstrap.sh
tmux new -A -s my-project
pi
```

之後可從任何裝置執行：

```bash
ssh your-server
tmux attach -t my-project
```

高風險或無人監看的 agent 工作，請使用 `docker compose -f ops/docker-compose.pi.yml run --rm pi`，並依需要調整 `.pi/sandbox.json`。完整說明見 [docs/remote-host.md](docs/remote-host.md)。

## 目錄

| 路徑 | 用途 |
|---|---|
| `AGENTS.md` | 所有 coding agent 必須遵守的穩定規則 |
| `PRD_EXECUTION.md` | PRD lifecycle、branch、review 與 merge gate |
| `.trellis/spec/` | 可重用的工程規範 |
| `.trellis/tasks/` | PRD 與執行紀錄 |
| `.pi/skills/` | 可重用的 Pi 工作流程 |
| `.github/workflows/` | GitHub CI 與 agent smoke check |
| `ops/` | 新機、Docker、SSH/tmux 與 dotfiles 輔助檔 |

## 認證與安全

Pi 認證使用互動式 `/login` 或主機環境變數；不要在 workflow 或 shell script 寫入 token。GitHub repository 建議啟用 secret scanning、push protection、branch protection 與 required status checks。

## 從模板開始建立新專案

請先複製整個 repo，再替換本專案的 `package.json`、`pyproject.toml` 或其他應用程式檔案。保留 `verify.sh` 的入口，讓它委派到專案真正的 lint、typecheck、test、build 命令。

