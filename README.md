# Spec-Driven AI Development Framework

這是一套跨語言的產品開發流程模板：Trellis 管理 Spec/PRD，Pi 執行單一 PRD，mise 提供工具與任務入口，原生建置工具負責語言領域，Git/CI 建立不可繞過的品質 gate。

它適合 Web、Python、Kotlin/Android、Qt/C++、C、CLI、桌面應用、服務、函式庫與多語言 monorepo。它不提供產品業務程式碼，也不取代 Gradle、CMake、uv、pnpm、Docker 或平台 SDK。

## Quick Start

```bash
git clone https://github.com/Pie-ye/spec-driven-ai-template.git my-project
cd my-project
curl https://mise.run | sh
mise install                 # 只安裝 core shellcheck/shfmt
./scripts/list-profiles.sh
./scripts/enable-profile.sh python
mise run doctor
mise run setup
mise run verify
```

未啟用 Profile 時，核心不會安裝 Node、Python、Java、Qt、GCC 或 Clang。Profile 只會透過明確的 `.template/profiles.toml` 啟用；檔案偵測只在 `doctor` 中提供建議，不會自行修改設定。

## Profile

可用 Profile：`python`、`web`、`kotlin`、`qt-cpp`、`c`。

```bash
./scripts/enable-profile.sh python
./scripts/enable-profile.sh qt-cpp
mise run profile:list
```

每個 Profile 有自己的 `mise.toml`、`AGENTS.md`、README 與 task adapter。Profile 使用原生工具：Python 使用 `pyproject.toml`/`uv.lock`，Web 使用 `package.json`/`pnpm-lock.yaml`，Kotlin 使用 `./gradlew`，C/Qt 使用 `CMakeLists.txt`/`CMakePresets.json`。Qt SDK、Android SDK、compiler ABI 等平台依賴由主機、IDE、container 或 toolchain file 提供。

多語言 monorepo 在 `.template/profiles.toml` 宣告：

```toml
enabled = ["python", "web"]

[modules.backend]
path = "services/backend"
profile = "python"

[modules.frontend]
path = "apps/web"
profile = "web"
```

## 統一任務

```text
doctor setup dev format format-check lint typecheck test build verify clean
```

本機和 CI 都使用：

```bash
mise run doctor
mise run setup
mise run verify
```

缺少可選 task 會明確顯示 `SKIP`；啟用 Profile 的必要 adapter 或命令失敗會使 verify 失敗。根目錄不猜測技術棧、不自行拼出另一套 CI 命令。

## PRD 工作流

```text
Spec → PRD backlog → one PRD → branch → Pi implement → mise verify → independent review → CI → merge
```

```bash
./scripts/create-prd-branch.sh PRD-001 cross-language-template-foundation
mise run verify
./scripts/finish-prd.sh PRD-001
git push -u origin prd/PRD-001-cross-language-template-foundation
```

PRD、Spec、Research、ADR、Review、Retro 模板位於 `.trellis/`。Pi 在修改前必須讀取 root/module `AGENTS.md` 與完整 PRD，不能擴張 scope、隱藏失敗或自動合併 `main`。

## Pi 工作流

使用 `.pi/prompts/execute-prd.md`、`.pi/prompts/review-prd.md` 與 `.pi/skills/`。主要寫入 Agent 一次只能有一個；explorer、test designer、reviewer 應保持唯讀。Pi 認證與 provider token 保留在主機環境，不提交至此 repo。

## CI

`.github/workflows/verify.yml` 先安裝 mise，執行 `mise run doctor`、`mise run setup`、`mise run verify`。`pr-policy.yml` 檢查 PRD branch、PRD ID 與 evidence 表。Profile matrix 可由後續專案或 CI runner 啟用，不在核心 workflow 偷渡未啟用語言工具。

## 目錄

| 路徑 | 用途 |
|---|---|
| `.template/profiles.toml` | 明確 capability/module manifest |
| `profiles/` | profile-local tools、rules、native task adapters |
| `scripts/` | core dispatcher、doctor、setup、branch、finish、tests |
| `.trellis/specs/` | product/engineering specs |
| `.trellis/prds/` | canonical PRDs and evidence |
| `.trellis/research/`, `decisions/`, `reviews/`, `retrospectives/` | durable engineering records |
| `.pi/` | Pi prompts、agents、skills、sandbox |
| `.github/` | CI、PR template、PR policy |

## 安全

Secrets 不可提交；`.env` 已忽略，`.env.example` 只能放非敏感值。Scripts 禁止 `git reset --hard`、`git clean -fdx`、force push、自動刪 branch 與自動 merge。Agent 不得讀取 `~/.ssh`、`~/.gnupg` 或專案外 secrets。此模板不包含也不依賴 cc-switch、OpenUsage 或 provider quota management。

## 其他主機

```bash
git clone https://github.com/Pie-ye/spec-driven-ai-template.git ~/code/my-project
cd ~/code/my-project
./.trellis/scripts/bootstrap.sh
mise install
tmux new -A -s my-project
```

更多說明見 [docs/getting-started.md](docs/getting-started.md)、[docs/development-workflow.md](docs/development-workflow.md) 與 [docs/profile-authoring.md](docs/profile-authoring.md)。
