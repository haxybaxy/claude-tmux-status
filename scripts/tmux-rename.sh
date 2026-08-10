#!/usr/bin/env bash
# tmux-rename.sh — Show Claude Code session state in the tmux window name.
#
# Usage: tmux-rename.sh <state>   → render "<base> [icon]" (idle/processing/attention)
#        tmux-rename.sh           → session teardown: drop the icon and put back the
#                                   window name that was there before the session
#
# The base name is the Claude Code session title (what `/rename` sets) when tmux can
# see it, and the window's own name otherwise. Set `@claude_tmux_status_title` to
# "off" to always use the window's own name.
#
# The user's `automatic-rename` setting is never modified.

set -euo pipefail
[[ -z "${TMUX_PANE:-}" ]] && exit 0

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

ORIG_OPT='@claude_tmux_status_orig'    # window name from before we first renamed it
TITLE_OPT='@claude_tmux_status_title'  # "off" disables session-title sourcing

# Claude prefixes its terminal title with a status glyph and a space — "✳" when idle,
# a braille spinner frame while it works. Match the shape rather than any one glyph,
# so the title still resolves mid-task. The {1,4} span covers both a single character
# and its raw bytes under a non-UTF-8 locale.
TITLE_RE='^[^[:alnum:][:space:]]{1,4}[[:space:]]+(.+)$'
ICON_RE='^(.*) \[[^][]*\]$'

# Window-scoped option (per window, never inherited).
get_window_opt() {
  tmux show-options -wqv -t "$TMUX_PANE" "$1" 2>/dev/null || true
}

set_window_opt() {
  tmux set-option -w -t "$TMUX_PANE" "$1" "$2" 2>/dev/null || true
}

unset_window_opt() {
  tmux set-option -w -u -t "$TMUX_PANE" "$1" 2>/dev/null || true
}

# User setting: per-window first, then the global value from .tmux.conf.
get_user_opt() {
  local value
  value=$(get_window_opt "$1")
  if [[ -z "$value" ]]; then
    value=$(tmux show-options -gqv "$1" 2>/dev/null || true)
  fi
  printf '%s' "$value"
}

window_name() {
  tmux display-message -p -t "$TMUX_PANE" '#W' 2>/dev/null || true
}

# Drop a trailing " [icon]" — and only that, so a window genuinely named
# "my project" keeps both of its words.
strip_icon() {
  local name="$1"
  if [[ "$name" =~ $ICON_RE ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  else
    printf '%s' "$name"
  fi
}

# The Claude session title, or nothing if tmux can't see one.
session_title() {
  local title
  [[ "$(get_user_opt "$TITLE_OPT")" == "off" ]] && return 0
  title=$(tmux display-message -p -t "$TMUX_PANE" '#{pane_title}' 2>/dev/null || true)
  if [[ "$title" =~ $TITLE_RE ]]; then
    printf '%s' "${BASH_REMATCH[1]}"
  fi
}

base_name() {
  local base
  base=$(session_title)
  [[ -n "$base" ]] || base=$(strip_icon "$(window_name)")
  [[ -n "$base" ]] || base=$(window_name)
  printf '%s' "$base"
}

icon_for() {
  local state="$1" icon="" conf="${PLUGIN_ROOT}/config/active.conf"

  if [[ -f "$conf" ]]; then
    icon=$(grep "^${state}=" "$conf" 2>/dev/null | cut -d= -f2- || true)
  fi

  # Fall back to defaults if the config is missing or lacks this state.
  if [[ -z "$icon" ]]; then
    case "$state" in
      idle)       icon="😴" ;;
      processing) icon="🧑‍🍳" ;;
      attention)  icon="👀" ;;
      *)          icon="$state" ;;  # pass through raw icons (backward compat)
    esac
  fi

  printf '%s' "$icon"
}

# Record the window's own name once, before a session title can replace it.
remember_original() {
  local original
  [[ -n "$(get_window_opt "$ORIG_OPT")" ]] && return 0
  original=$(strip_icon "$(window_name)")
  [[ -n "$original" ]] && set_window_opt "$ORIG_OPT" "$original"
}

rename_to() {
  [[ -n "$1" ]] && tmux rename-window -t "$TMUX_PANE" "$1"
}

if [[ $# -ge 1 ]]; then
  remember_original
  rename_to "$(base_name) [$(icon_for "$1")]"
else
  RESTORED=$(get_window_opt "$ORIG_OPT")
  [[ -n "$RESTORED" ]] || RESTORED=$(base_name)
  rename_to "$RESTORED"
  unset_window_opt "$ORIG_OPT"
fi
