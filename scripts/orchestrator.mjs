#!/usr/bin/env node

import crypto from "node:crypto";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import { fileURLToPath } from "node:url";
import { spawnSync } from "node:child_process";

const ROOT = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
let RUN_ROOT = path.join(ROOT, ".trellis", "runs");
const PHASES = ["intake", "specify", "plan", "approve", "implement", "verify", "debug", "review", "deliver", "archive"];
const STATUSES = ["pending", "running", "blocked", "waiting_approval", "succeeded", "failed"];
const GATES = ["prd_scope", "risk", "final_diff", "merge", "deploy"];
const SAFE_ID = /^[A-Za-z0-9][A-Za-z0-9._-]*$/;

function usage() {
  console.log(`Usage:
  orchestrator.mjs init <PRD-ID> [session-id] [branch]
  orchestrator.mjs state <PRD-ID> <session-id>
  orchestrator.mjs resume <PRD-ID> <session-id>
  orchestrator.mjs replay <PRD-ID> <session-id>
  orchestrator.mjs transition <PRD-ID> <session-id> <phase> <status>
  orchestrator.mjs gate request|approve|reject <PRD-ID> <session-id> <gate> [reason]
  orchestrator.mjs lock acquire|release|force-release <PRD-ID> <session-id> [owner]
  orchestrator.mjs record-tool <PRD-ID> <session-id> <command> <cwd> <exit-code>
  orchestrator.mjs self-test

record-tool reads command output from stdin and stores a redacted local artifact.
All state and artifacts stay inside the current local clone.`);
}

function fail(message, code = 1) {
  console.error(`[orchestrator] ERROR: ${message}`);
  process.exitCode = code;
  throw new Error(message);
}

function assertId(value, label) {
  if (!value || !SAFE_ID.test(value) || value === "." || value === ".." || value.includes("..")) {
    fail(`Invalid ${label}: ${value}`);
  }
}

function assertPrd(value) {
  assertId(value, "PRD ID");
  if (!/^PRD-[0-9]+$/.test(value)) fail(`PRD ID must look like PRD-001: ${value}`);
}

function runDir(prdId, sessionId) {
  assertPrd(prdId);
  assertId(sessionId, "session ID");
  return path.join(RUN_ROOT, prdId, sessionId);
}

function statePath(run) { return path.join(run, "state.json"); }
function eventPath(run) { return path.join(run, "events.jsonl"); }
function lockPath(run, name) { return path.join(run, name); }

function ensureDir(dir) { fs.mkdirSync(dir, { recursive: true }); }

function readJson(file) {
  return JSON.parse(fs.readFileSync(file, "utf8"));
}

function writeJsonAtomic(file, value) {
  ensureDir(path.dirname(file));
  const temp = `${file}.${process.pid}.${crypto.randomUUID()}.tmp`;
  fs.writeFileSync(temp, `${JSON.stringify(value, null, 2)}\n`, { mode: 0o600 });
  fs.renameSync(temp, file);
}

function sleep(milliseconds) {
  const shared = new SharedArrayBuffer(4);
  Atomics.wait(new Int32Array(shared), 0, 0, milliseconds);
}

function acquireFileLock(file, owner, timeoutMs = 5000) {
  const started = Date.now();
  ensureDir(path.dirname(file));
  while (Date.now() - started < timeoutMs) {
    try {
      const fd = fs.openSync(file, "wx", 0o600);
      fs.writeFileSync(fd, JSON.stringify({ owner, pid: process.pid, acquired_at: new Date().toISOString() }));
      fs.closeSync(fd);
      return;
    } catch (error) {
      if (error.code !== "EEXIST") throw error;
      sleep(25);
    }
  }
  fail(`Timed out waiting for lock: ${file}`);
}

function releaseFileLock(file) {
  try { fs.unlinkSync(file); } catch (error) { if (error.code !== "ENOENT") throw error; }
}

function withStateLock(run, fn) {
  const lock = lockPath(run, "state.lock");
  const owner = `state-${process.pid}-${crypto.randomUUID()}`;
  acquireFileLock(lock, owner);
  try { return fn(); } finally { releaseFileLock(lock); }
}

function baseState(prdId, sessionId, branch) {
  return {
    schema_version: 1,
    session_id: sessionId,
    prd_id: prdId,
    branch: branch || currentBranch(),
    base_commit: currentCommit(),
    phase: "intake",
    status: "running",
    attempt: 0,
    writer_lock: null,
    pending_gates: [],
    approvals: {},
    rejected_gates: {},
    artifacts: [],
    criteria: [],
    last_sequence: 0,
    created_at: new Date().toISOString(),
    updated_at: new Date().toISOString(),
  };
}

function currentBranch() {
  const result = spawnSync("git", ["branch", "--show-current"], { cwd: ROOT, encoding: "utf8" });
  return result.status === 0 ? result.stdout.trim() || null : null;
}

function currentCommit() {
  const result = spawnSync("git", ["rev-parse", "HEAD"], { cwd: ROOT, encoding: "utf8" });
  return result.status === 0 ? result.stdout.trim() : null;
}

function loadState(prdId, sessionId) {
  const run = runDir(prdId, sessionId);
  if (!fs.existsSync(statePath(run))) fail(`Session not found: ${prdId}/${sessionId}`);
  return { run, state: readJson(statePath(run)) };
}

function appendEventUnlocked(run, state, kind, phase, payload, actor = { type: "orchestrator", id: String(process.pid) }) {
  const sequence = state.last_sequence + 1;
  const event = {
    schema_version: 1,
    event_id: crypto.randomUUID(),
    session_id: state.session_id,
    sequence,
    timestamp: new Date().toISOString(),
    kind,
    phase: phase || state.phase,
    actor,
    payload: payload || {},
    redactions: [],
  };
  fs.appendFileSync(eventPath(run), `${JSON.stringify(event)}\n`, { mode: 0o600 });
  return { ...state, last_sequence: sequence, updated_at: event.timestamp };
}

function mutate(prdId, sessionId, kind, phase, payload, patch = {}) {
  const { run } = loadState(prdId, sessionId);
  return withStateLock(run, () => {
    const state = readJson(statePath(run));
    const next = appendEventUnlocked(run, state, kind, phase, payload);
    writeJsonAtomic(statePath(run), { ...next, ...patch, updated_at: new Date().toISOString() });
    return readJson(statePath(run));
  });
}

function init(prdId, sessionId = `${new Date().toISOString().replace(/[:.]/g, "-")}-${crypto.randomUUID().slice(0, 8)}`, branch) {
  assertPrd(prdId);
  assertId(sessionId, "session ID");
  const run = runDir(prdId, sessionId);
  if (fs.existsSync(statePath(run))) {
    console.log(JSON.stringify(readJson(statePath(run)), null, 2));
    return;
  }
  ensureDir(path.join(run, "artifacts"));
  ensureDir(path.join(run, "failures"));
  fs.writeFileSync(eventPath(run), "", { mode: 0o600 });
  const state = baseState(prdId, sessionId, branch);
  writeJsonAtomic(statePath(run), state);
  mutate(prdId, sessionId, "session.created", "intake", { branch: state.branch, base_commit: state.base_commit });
  console.log(JSON.stringify(readJson(statePath(run)), null, 2));
}

function transition(prdId, sessionId, phase, status) {
  if (!PHASES.includes(phase)) fail(`Unknown phase: ${phase}`);
  if (!STATUSES.includes(status)) fail(`Unknown status: ${status}`);
  const state = mutate(prdId, sessionId, "phase.transitioned", phase, { phase, status }, { phase, status });
  console.log(JSON.stringify(state, null, 2));
}

function gate(action, prdId, sessionId, gate, reason = "") {
  if (!GATES.includes(gate)) fail(`Unknown gate: ${gate}`);
  const { run } = loadState(prdId, sessionId);
  const state = withStateLock(run, () => {
    const current = readJson(statePath(run));
    if (action === "request") {
      if (current.pending_gates.includes(gate)) return current;
      const next = appendEventUnlocked(run, current, "gate.requested", "approve", { gate, reason }, { type: "orchestrator", id: String(process.pid) });
      writeJsonAtomic(statePath(run), { ...next, phase: "approve", status: "waiting_approval", resume_phase: current.phase, pending_gates: [...current.pending_gates, gate] });
    } else if (action === "approve") {
      if (!current.pending_gates.includes(gate)) fail(`Gate is not pending: ${gate}`);
      const next = appendEventUnlocked(run, current, "gate.approved", current.resume_phase || current.phase, { gate, reason }, { type: "user", id: process.env.USER || "local" });
      const pending = current.pending_gates.filter((item) => item !== gate);
      writeJsonAtomic(statePath(run), { ...next, phase: pending.length ? "approve" : (current.resume_phase || "intake"), status: pending.length ? "waiting_approval" : "running", pending_gates: pending, approvals: { ...current.approvals, [gate]: { reason, approved_at: new Date().toISOString() } } });
    } else if (action === "reject") {
      const next = appendEventUnlocked(run, current, "gate.rejected", "approve", { gate, reason }, { type: "user", id: process.env.USER || "local" });
      writeJsonAtomic(statePath(run), { ...next, phase: "approve", status: "blocked", rejected_gates: { ...current.rejected_gates, [gate]: { reason, rejected_at: new Date().toISOString() } } });
    } else {
      fail(`Unknown gate action: ${action}`);
    }
    return readJson(statePath(run));
  });
  console.log(JSON.stringify(state, null, 2));
}

function lock(action, prdId, sessionId, owner = process.env.ORCHESTRATOR_OWNER || `${process.pid}`) {
  const { run } = loadState(prdId, sessionId);
  const file = lockPath(run, "writer.lock");
  if (action === "acquire") {
    if (fs.existsSync(file)) {
      const current = readJson(file);
      if (current.owner === owner) return console.log(JSON.stringify(current, null, 2));
      fail(`Writer lock is held by ${current.owner}`);
    }
    acquireFileLock(file, owner);
    const value = { owner, pid: process.pid, acquired_at: new Date().toISOString() };
    fs.writeFileSync(file, JSON.stringify(value), { mode: 0o600 });
    const state = mutate(prdId, sessionId, "writer.locked", "implement", { owner }, { writer_lock: value });
    console.log(JSON.stringify(state, null, 2));
    return;
  }
  if (action === "release" || action === "force-release") {
    if (!fs.existsSync(file)) return console.log(JSON.stringify(readJson(statePath(run)), null, 2));
    const current = readJson(file);
    if (action !== "force-release" && current.owner !== owner) fail(`Writer lock is held by ${current.owner}`);
    releaseFileLock(file);
    const state = mutate(prdId, sessionId, action === "force-release" ? "writer.force_released" : "writer.released", "implement", { owner: current.owner }, { writer_lock: null });
    console.log(JSON.stringify(state, null, 2));
    return;
  }
  fail(`Unknown lock action: ${action}`);
}

function redact(value) {
  return value
    .replace(/(authorization\s*:\s*bearer\s+)[^\s]+/gi, "$1[REDACTED]")
    .replace(/((?:api[_-]?key|token|password|secret)\s*[=:]\s*)[^\s,;]+/gi, "$1[REDACTED]")
    .replace(/(sk-[A-Za-z0-9_-]{12,}|xai-[A-Za-z0-9_-]{12,}|gh[pousr]_[A-Za-z0-9_-]{12,})/g, "[REDACTED]");
}

function recordToolOutput(prdId, sessionId, command, cwd, exitCode, output) {
  const { run } = loadState(prdId, sessionId);
  const safeOutput = redact(output);
  const numericExitCode = Number(exitCode);
  if (!Number.isInteger(numericExitCode) || numericExitCode < 0) fail(`Invalid exit code: ${exitCode}`);
  const state = withStateLock(run, () => {
    const current = readJson(statePath(run));
    const sequence = current.last_sequence + 1;
    const artifact = `artifacts/tool-${String(sequence).padStart(4, "0")}.log`;
    fs.writeFileSync(path.join(run, artifact), safeOutput, { mode: 0o600 });
    const succeeded = numericExitCode === 0;
    const next = appendEventUnlocked(run, current, succeeded ? "tool.completed" : "tool.failed", current.phase, { command: redact(command), cwd, exit_code: numericExitCode, artifact });
    writeJsonAtomic(statePath(run), { ...next, status: succeeded ? current.status : "failed", artifacts: [...current.artifacts, artifact] });
    return readJson(statePath(run));
  });
  console.log(JSON.stringify(state, null, 2));
}

function recordTool(prdId, sessionId, command, cwd, exitCode) {
  return recordToolOutput(prdId, sessionId, command, cwd, exitCode, fs.readFileSync(0, "utf8"));
}

function replay(prdId, sessionId) {
  const { run, state } = loadState(prdId, sessionId);
  const lines = fs.readFileSync(eventPath(run), "utf8").split("\n").filter(Boolean).map((line) => JSON.parse(line));
  lines.forEach((event, index) => {
    if (event.sequence !== index + 1) fail(`Event sequence gap at ${index + 1}`);
  });
  if (state.last_sequence !== lines.length) fail(`State/event mismatch: state=${state.last_sequence}, events=${lines.length}`);
  console.log(JSON.stringify({ session_id: state.session_id, events: lines.length, last_event: lines.at(-1) || null, state }, null, 2));
}

function selfTest() {
  const temp = fs.mkdtempSync(path.join(os.tmpdir(), "vibecoding-orchestrator-"));
  const previousRunRoot = RUN_ROOT;
  const quiet = (fn) => {
    const log = console.log;
    console.log = () => {};
    try { return fn(); } finally { console.log = log; }
  };
  try {
    RUN_ROOT = temp;
    const session = "self-test";
    const agents = fs.readFileSync(path.join(ROOT, "AGENTS.md"), "utf8");
    const prd = fs.readFileSync(path.join(ROOT, ".trellis", "prds", "PRD-002-vibecoding-orchestrator.md"), "utf8");
    if (!agents.includes(".trellis") || !prd.includes("PRD-002")) throw new Error("smoke fixture could not read project context");
    quiet(() => init("PRD-999", session, "prd/PRD-999-self-test"));
    quiet(() => init("PRD-999", session, "prd/PRD-999-self-test"));
    if (loadState("PRD-999", session).state.last_sequence !== 1) throw new Error("repeated init was not idempotent");
    quiet(() => gate("request", "PRD-999", session, "prd_scope"));
    let state = loadState("PRD-999", session).state;
    if (state.status !== "waiting_approval") throw new Error("approval gate did not pause session");
    quiet(() => gate("approve", "PRD-999", session, "prd_scope", "self-test"));
    quiet(() => lock("acquire", "PRD-999", session, "self-test-owner"));
    quiet(() => lock("release", "PRD-999", session, "self-test-owner"));
    quiet(() => recordToolOutput("PRD-999", session, "printf test", ROOT, "0", "token=secret-value\nresult=pass\n"));
    const artifact = path.join(runDir("PRD-999", session), "artifacts", "tool-0006.log");
    const artifactText = fs.readFileSync(artifact, "utf8");
    if (artifactText.includes("secret-value")) throw new Error("tool artifact did not redact secret");
    quiet(() => recordToolOutput("PRD-999", session, "false", ROOT, "1", "failure=expected\n"));
    state = loadState("PRD-999", session).state;
    if (state.status !== "failed") throw new Error("failed tool did not mark session failed");
    quiet(() => transition("PRD-999", session, "verify", "succeeded"));
    quiet(() => replay("PRD-999", session));
    state = loadState("PRD-999", session).state;
    const events = fs.readFileSync(eventPath(runDir("PRD-999", session)), "utf8").trim().split("\n").filter(Boolean);
    if (state.last_sequence !== events.length || events.length < 6) throw new Error("event replay did not observe expected events");
    console.log("orchestrator self-test: PASS");
  } finally {
    RUN_ROOT = previousRunRoot;
    fs.rmSync(temp, { recursive: true, force: true });
  }
}

function main(args) {
  const command = args[0];
  if (!command || command === "--help" || command === "-h") return usage();
  if (command === "self-test") return selfTest();
  if (command === "init") return init(args[1], args[2], args[3]);
  if (command === "state" || command === "resume") return console.log(JSON.stringify(loadState(args[1], args[2]).state, null, 2));
  if (command === "replay") return replay(args[1], args[2]);
  if (command === "transition") return transition(args[1], args[2], args[3], args[4]);
  if (command === "gate") return gate(args[1], args[2], args[3], args[4], args.slice(5).join(" "));
  if (command === "lock") return lock(args[1], args[2], args[3], args[4]);
  if (command === "record-tool") return recordTool(args[1], args[2], args[3], args[4], args[5]);
  fail(`Unknown command: ${command}`);
}

try { main(process.argv.slice(2)); } catch (error) { if (process.exitCode !== 1) process.exitCode = 1; if (process.env.ORCHESTRATOR_DEBUG) console.error(error.stack); }
