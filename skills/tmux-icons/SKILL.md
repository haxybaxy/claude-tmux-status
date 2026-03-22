---
name: tmux-icons
description: Switch tmux status icon themes or customize individual icons for the claude-tmux-status plugin. Use when user says "change tmux icons", "switch tmux theme", "set tmux icons", or wants to customize tmux status indicators.
argument-hint: [theme-name | set <state> <icon> | list | reset]
allowed-tools: [Read, Write, Bash, Glob]
---

# tmux-icons: Theme and Icon Customization

Manage the icon theme for the claude-tmux-status plugin. Changes take effect immediately on the next Claude Code lifecycle event (no restart needed).

## Arguments

The user invoked this with: $ARGUMENTS

## Plugin Location

The plugin root is at: $CLAUDE_PLUGIN_ROOT

If `$CLAUDE_PLUGIN_ROOT` is empty or not set, check `~/.claude/plugins/` for the `claude-tmux-status` directory.

## Configuration Files

- **Active config**: `$CLAUDE_PLUGIN_ROOT/config/active.conf` — key=value file with `idle`, `processing`, `attention` mappings
- **Theme presets**: `$CLAUDE_PLUGIN_ROOT/config/themes/*.json` — JSON files with `name`, `description`, and `icons` fields

## Actions

### No arguments or "list"
Show the current active config and list all available themes with their icons in a comparison table.

### Theme name (e.g., "emoji", "nerd-font", "minimal")
1. Read the theme JSON from `$CLAUDE_PLUGIN_ROOT/config/themes/<name>.json`
2. Write the icons to `$CLAUDE_PLUGIN_ROOT/config/active.conf` in `key=value` format (one per line: `idle=<icon>`, `processing=<icon>`, `attention=<icon>`)
3. Confirm the change and show the new active icons

### "set <state> <icon>" (e.g., "set attention !!")
1. Read current `active.conf`
2. Replace the line for the given state with the new icon
3. Write back `active.conf`
4. Valid states: `idle`, `processing`, `attention`

### "reset"
1. Read the emoji theme from `$CLAUDE_PLUGIN_ROOT/config/themes/emoji.json`
2. Write it to `active.conf`
3. Confirm reset to defaults

### "create <name>"
1. Ask the user for icons for each state (idle, processing, attention)
2. Create a new theme JSON at `$CLAUDE_PLUGIN_ROOT/config/themes/<name>.json`
3. Optionally activate it

## Response Format

After any change, show the resulting active configuration:

```
Active tmux icons:
  idle:       <icon>
  processing: <icon>
  attention:  <icon>
```
