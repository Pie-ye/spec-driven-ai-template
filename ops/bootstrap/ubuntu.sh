#!/usr/bin/env bash
set -euo pipefail

sudo apt-get update
sudo apt-get install -y bash zsh tmux git curl jq unzip zip rsync openssh-client ca-certificates build-essential pkg-config libssl-dev

if ! command -v mise >/dev/null 2>&1; then
  curl https://mise.run | sh
fi

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
if command -v mise >/dev/null 2>&1; then mise install; fi
if ! command -v pi >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  npm install -g --ignore-scripts @earendil-works/pi-coding-agent
fi
echo "[bootstrap/ubuntu] complete"
