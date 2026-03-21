#!/usr/bin/env bash
# tmux-rename.sh — Set/remove a Nerd Font suffix on the current tmux window.
# Usage: tmux-rename.sh <suffix>  → replace old suffix with new one
#        tmux-rename.sh           → strip suffix, re-enable automatic-rename

set -euo pipefail
[[ -z "${TMUX_PANE:-}" ]] && exit 0

CURRENT=$(tmux display-message -p -t "$TMUX_PANE" '#W')
CLEAN="${CURRENT% *}"

if [[ $# -ge 1 ]]; then
  tmux rename-window -t "$TMUX_PANE" "${CLEAN} $1"
else
  tmux rename-window -t "$TMUX_PANE" "$CLEAN"
  tmux set-window-option -t "$TMUX_PANE" automatic-rename on
fi
