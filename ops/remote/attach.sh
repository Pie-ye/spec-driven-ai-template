#!/usr/bin/env bash
set -euo pipefail

session="${1:-my-project}"
tmux new-session -A -s "$session"

