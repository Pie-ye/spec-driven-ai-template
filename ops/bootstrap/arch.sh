#!/usr/bin/env bash
set -euo pipefail

sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm bash zsh tmux git curl jq unzip zip rsync openssh base-devel pkgconf openssl mise nodejs npm
export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
mise install
npm install -g --ignore-scripts @earendil-works/pi-coding-agent
echo "[bootstrap/arch] complete"
