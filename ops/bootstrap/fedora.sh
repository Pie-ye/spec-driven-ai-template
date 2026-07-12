#!/usr/bin/env bash
set -euo pipefail

sudo dnf update -y
sudo dnf install -y bash zsh tmux git curl jq unzip zip rsync openssh-clients ca-certificates gcc gcc-c++ make pkgconf-pkg-config openssl-devel nodejs npm
if ! command -v mise >/dev/null 2>&1; then curl https://mise.run | sh; fi
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
mise install
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
echo "[bootstrap/fedora] complete"
