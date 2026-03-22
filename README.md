# claude-tmux-status

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that shows session state as emoji icons in your tmux window name.

```
 zsh              — no session
 zsh [😴]          — idle
 zsh [🧑‍🍳]          — thinking / tool use
 zsh [👀]          — needs attention (permission request / notification)
```

## Requirements

- [tmux](https://github.com/tmux/tmux)
- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI

## Install

### Via Claude Code Plugin Marketplace (recommended)

From inside Claude Code, run:

```
/plugin marketplace add https://github.com/haxybaxy/claude-tmux-status.git
```

Then install the plugin:

```
/plugin install claude-tmux-status
```

Finally, activate it:

```
/reload-plugins
```

### Manual

Clone into your Claude Code plugins directory:

```bash
git clone https://github.com/haxybaxy/claude-tmux-status \
  ~/.claude/plugins/claude-tmux-status
```

Claude Code picks up the plugin automatically on next launch.

## How it works

The plugin registers [hooks](https://docs.anthropic.com/en/docs/claude-code/hooks) for Claude Code lifecycle events. Each event runs a small bash script that appends or removes an icon suffix on the current tmux window name.

| Event | Icon | State |
|-------|------|-------|
| `SessionStart` | `😴` | Idle |
| `UserPromptSubmit` | `🧑‍🍳` | Processing |
| `PreToolUse` | `🧑‍🍳` | Processing |
| `PostToolUse` | `🧑‍🍳` | Processing |
| `Stop` | `😴` | Idle |
| `PermissionRequest` | `👀` | Needs attention |
| `Notification` | `👀` | Needs attention |
| `SessionEnd` | *(removed)* | Cleans up and re-enables `automatic-rename` |

## Customization

Edit `hooks/hooks.json` to swap icons to any emoji you prefer.

## License

MIT
