# PRD-002：自然語言驅動的 VibeCoding Orchestrator

| Field | Value |
|---|---|
| ID | PRD-002 |
| Priority | P0 |
| Status | Ready |
| Branch | `prd/PRD-002-vibecoding-orchestrator` |
| Dependencies | PRD-001 cross-language framework foundation |
| Merge target | `main` |
| Follow-up | PRD-003 Trellis lifecycle automation, PRD-004 cross-language CI profiles |

## 1. Background

PRD-001 建立了跨語言 Profile、mise task contract、Trellis canonical records、Pi prompt、CI 與 review gate。但目前使用者仍需要自行選擇腳本、建立文件、啟動工具與安排執行順序。

本 PRD 將 Pi 提升為自然語言驅動的 VibeCoding orchestration engine。使用者只描述想法、目標與偏好，Pi 負責將需求轉換為可追蹤的 Spec/PRD，規劃並執行設計、實作、除錯、測試、驗證與 review 工作，並透過多個受控 subagent 與工具平行處理可獨立的工作。

## 2. Problem

現在的流程元件各自存在，但缺少一個具備持久狀態的協調層：

- 自然語言需求沒有穩定地轉成 Spec 與 PRD。
- Pi prompt、Profile tasks、測試、review 與 Git branch 需要人工串接。
- 多個 subagent 若同時寫入同一 working tree，容易產生衝突、越界修改與無法追蹤的狀態。
- 除錯通常是線性重試，沒有依失敗證據平行啟動 diagnostics、test analysis、security analysis 與 documentation analysis。
- Agent 的「完成」宣告不一定包含每個 acceptance criterion 的證據。

## 3. Goal

讓使用者可以只透過自然語言啟動一份可審查、可恢復、可驗證的 VibeCoding session：

```text
自然語言想法
  → repository discovery
  → Spec proposal
  → PRD proposal
  → 使用者批准
  → PRD branch
  → design / implementation / test / security subagents
  → controlled tool execution
  → debug loop
  → mise verify
  → independent review
  → Pull Request
  → 使用者批准 merge
  → PRD archive
```

## 4. User experience

使用者可以輸入：

> 我想在這個專案加入使用者 session expiry，閒置 30 分鐘失效，保留 remember-me，補上測試並更新文件。

Pi 應自動：

1. 讀取 root/module `AGENTS.md`、現有 Specs、Profiles、PRD backlog 與 repository baseline。
2. 判斷這是新功能、bug、重構、migration、文件或多種類型組合。
3. 提出或更新 Product Spec。
4. 產生 PRD、non-goals、依賴、風險、測試計畫、rollback 與 evidence table。
5. 在需要批准的 gate 停下，讓使用者修改或確認 Spec/PRD。
6. 從最新 `main` 建立 PRD branch。
7. 自動安排 design、exploration、test design、implementation、debug、security、review 等工作。
8. 使用 Profile task contract 與 native build tools 執行命令。
9. 對失敗測試或 build 啟動有證據導向的除錯 subagent，修正後重新驗證。
10. 產生每個 acceptance criterion 的 evidence mapping、changed files、commands、logs 與風險報告。
11. 建立 Draft Pull Request，等待人工 review/merge；不得自行合併 `main`。

## 5. Scope

### 5.1 Natural-language intake

- 提供一個 Pi project-local orchestrator prompt/skill 作為自然語言入口。
- 支援新功能、bug、refactor、migration、test、docs 與跨模組需求分類。
- 對缺少的產品意圖提出最少但高價值的澄清問題。
- 不要求使用者知道 Profile、mise task、Trellis artifact 或 subagent 名稱。

### 5.2 Persistent orchestration state

每次 VibeCoding session 必須保存可恢復狀態，至少包含：

- session ID、PRD ID、branch、parent commit。
- current phase、phase status、attempt number。
- active agents、tool calls、依賴與 blocked reason。
- user approvals、scope changes、follow-up PRD。
- acceptance criteria evidence。
- command output、test/build reports 與 review results。

建議路徑：

```text
.trellis/runs/<PRD-ID>/<session-id>/
├── state.json
├── events.jsonl
├── context.md
├── plan.md
├── evidence.md
├── failures/
└── artifacts/
```

### 5.3 Phase orchestration

最少支援以下 phase：

| Phase | 目的 | 可平行工作 |
|---|---|---|
| intake | 理解自然語言需求與分類 | discovery、相關 Spec 搜尋 |
| specify | 產生或更新 Spec | alternatives、impact analysis |
| plan | 產生 PRD、design、implement plan | architecture、test design、risk review |
| approve | 使用者確認 scope 與風險 | 不執行寫入 |
| implement | 依 PRD 寫入程式碼與測試 | read-only explorer、test designer、security scout |
| verify | format/lint/typecheck/test/build | 可平行執行互不依賴的 checks |
| debug | 分析失敗並提出最小修正 | failure analysis、regression test、dependency analysis |
| review | 對照 PRD 與最終 diff | reviewer、security reviewer、docs reviewer |
| deliver | 建立 Draft PR 與完成報告 | evidence compaction、release note |
| archive | merge 後封存 PRD 與記錄 session | retrospective、spec distillation |

### 5.4 Subagent roles

最少提供以下角色：

- `repository-explorer`：唯讀探索架構、既有模式、模組與工具。
- `spec-analyst`：整理需求、限制、替代方案與未知點。
- `architect`：設計資料流、邊界、相容性與 rollback。
- `test-designer`：將每一個 acceptance criterion 轉成測試策略。
- `implementer`：唯一主要寫入 Agent，實作目前 PRD。
- `debugger`：根據失敗輸出找 root cause，提出最小修正。
- `security-reviewer`：檢查 secrets、權限、輸入、命令、路徑與網路邊界。
- `reviewer`：唯讀對照 PRD、diff、測試與 evidence。
- `documentation-writer`：只更新 PRD 要求範圍內的文件與操作說明。

除 `implementer` 外，subagent 預設不得修改主要 working tree。需要平行寫入時，必須使用獨立 worktree 或 artifact workspace，並由 orchestrator 以 diff/patch 方式整合。

### 5.5 Tool orchestration

Pi 必須透過可列舉的 tool registry 呼叫工具，不可由模型任意發明命令。工具至少分為：

- repository：read、grep、find、git status/diff/log。
- planning：Spec/PRD/ADR template、context compaction、evidence writer。
- execution：mise tasks、Profile adapters、native build commands。
- testing：targeted test、full verify、test report collection。
- debugging：failure parser、log search、regression test runner。
- collaboration：subagent dispatch、parallel job、worktree isolation。
- delivery：PR body、review summary、archive record。

所有 command invocation 必須記錄 command、cwd、profile/module、exit code、開始/結束時間與 output artifact 路徑；secrets 必須 redact。

### 5.6 Failure and debug loop

遇到 failure 時，orchestrator 必須：

1. 保存原始輸出，不覆寫失敗證據。
2. 將失敗分類為 environment、dependency、compile/type、test assertion、flaky、security、scope 或 unknown。
3. 啟動適當的唯讀 diagnostics subagents。
4. 產生 root-cause hypothesis 與可驗證的修正方案。
5. 由主要 implementer 實作修正與 regression test。
6. 只重跑受影響的 targeted checks，再重跑完整 `mise run verify`。
7. 達到 retry budget 後停止並要求使用者決策，不可無限循環。

## 6. Approval gates

Gate 必須是持久化狀態，不可只存在對話記憶。至少包含：

- Spec scope approval。
- PRD acceptance criteria approval。
- 高風險命令、外部網路、migration 或 secrets boundary approval。
- 最終 diff/evidence review approval。
- Merge approval。

未批准時，Pi 可以繼續唯讀探索與產生建議，但不可進入被 gate 阻擋的寫入或外部狀態變更。

### Confirmed approval policy

Pi may automatically run repository discovery, planning, tests, diagnostics, and commands inside the approved repository sandbox. Pi must pause for Spec/PRD scope approval, high-risk external or destructive actions, migrations, secrets-boundary changes, final diff/evidence approval, and merge/deploy approval.

## 7. Non-goals

- 不建立新的產品業務功能。
- 不取代 Trellis 作為 Spec/PRD source of truth。
- 不取代 Gradle、CMake、uv、pnpm、Docker 或平台 SDK。
- 不在本 PRD 管理 provider OAuth、額度、cc-switch 或 OpenUsage。
- 不允許多個 Agent 無隔離地同時修改同一 working tree。
- 不自動部署 production。
- 不自動 merge，除非使用者在明確 merge gate 給予批准。
- 不在第一次版本實作完整 GUI/TUI 控制台；CLI/Pi prompt 與 JSONL state 足以驗證核心流程。

## 8. Acceptance criteria

- [ ] AC-001：使用者只輸入自然語言需求，orchestrator 能產生 repository-grounded Spec/PRD proposal。
- [ ] AC-002：Spec 與 PRD 在進入寫入實作前必須經過持久化 approval gate。
- [ ] AC-003：orchestrator 能從 PRD 建立正確 branch，並將 PRD、session 與 branch 關聯。
- [ ] AC-004：Pi 能依 phase dispatch repository-explorer、architect、test-designer、implementer、debugger、security-reviewer、reviewer 等角色。
- [ ] AC-005：可平行的唯讀探索、測試設計、風險分析與 review 工作會平行執行；主要 working tree 同時最多一個 writer。
- [ ] AC-006：所有 Profile/Module 命令透過既有 mise task contract 執行，不由 orchestrator 硬編碼語言命令。
- [ ] AC-007：每次 tool call、subagent result、phase transition、approval、failure 與 retry 都持久化到 `.trellis/runs/`。
- [ ] AC-008：verify failure 會保存原始輸出、分類失敗、啟動 diagnostics、加入 regression test，並依 retry budget 停止。
- [ ] AC-009：完成報告逐項對應 acceptance criteria、changed files、tests、commands、CI 與 residual risks。
- [ ] AC-010：orchestrator 能建立 Draft PR，但不會自行 merge `main` 或部署 production。
- [ ] AC-011：使用者可從中斷的 session state 恢復，不需重新依賴原始對話上下文。
- [ ] AC-012：secrets、credential path、敏感 command output 會被阻擋或 redact，不進入 Git artifact。
- [ ] AC-013：核心流程可在無啟用 Profile 的模板上完成 intake/plan/verify smoke test。
- [ ] AC-014：CI 與本機使用相同的 orchestrator/`mise run verify` contract。

## 9. Test plan

### Unit/script tests

- phase state transition validity。
- manifest/profile/module dispatch。
- approval persistence and resume。
- retry budget and failure classification。
- single-writer lock。
- command/output redaction。
- duplicate event/idempotent resume handling。

### Integration tests

- natural language fixture → Spec → PRD → approval → branch → mock implementation → verify → evidence。
- parallel read-only subagents with deterministic aggregation。
- isolated worktree writer result integration。
- failed test → debugger → regression test → verify success。
- interrupted session → state restore without duplicate commits or tool calls。

### Security tests

- forbidden path and secret pattern blocking。
- shell injection and untrusted PRD text handling。
- network allowlist and approval requirement。
- no destructive Git command in orchestrator scripts。

### End-to-end

At least one fixture each for Python, Web, Kotlin, C, and Qt/C++ contract discovery; complete SDK builds may remain platform-specific and use CI profiles.

## 10. Definition of Done

- [ ] Orchestrator state machine and event schema are documented and implemented。
- [ ] Natural-language intake prompt/skill exists。
- [ ] Spec/PRD proposal and approval gates work。
- [ ] Subagent registry and parallel dispatch work with single-writer protection。
- [ ] Tool registry delegates to Profile/mise contract。
- [ ] Debug loop, retry budget, evidence writer, and session resume work。
- [ ] Draft PR creation works without merge/deploy side effects。
- [ ] Core, security, integration, and resume tests pass。
- [ ] CI passes using the same verification contract。
- [ ] Independent reviewer returns `READY_TO_MERGE`。

## 11. Evidence table

| AC | Status | Implementation | Evidence |
|---|---|---|---|
| AC-001 | Pending | | |
| AC-002 | Pending | | |
| AC-003 | Pending | | |
| AC-004 | Pending | | |
| AC-005 | Pending | | |
| AC-006 | Pending | | |
| AC-007 | Pending | | |
| AC-008 | Pending | | |
| AC-009 | Pending | | |
| AC-010 | Pending | | |
| AC-011 | Pending | | |
| AC-012 | Pending | | |
| AC-013 | Pending | | |
| AC-014 | Pending | | |

## 12. Planning status

Approval policy is confirmed by the user. The next step is technical design and implementation planning; no Pi engine code is included in this PRD draft.
