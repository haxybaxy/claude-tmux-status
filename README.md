# claude-tmux-status
<img width="620" height="57" alt="image" src="https://github.com/user-attachments/assets/883a7881-60a4-41f9-96b5-1ac4e185dffe" />

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) plugin that shows session state as emoji icons in your tmux window name.

```
 zsh              — no session
 zsh [🧑‍🍳]          — thinking / tool use
 zsh [👀]          — needs attention (permission request / notification)
 zsh [😴]          — idle
```

Name your session with `/rename` and the window follows along:

```
 Fix auth bug [🧑‍🍳]    — window named after the Claude session
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
/plugin install tmux-status
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

There is no background process — the script runs only when a hook fires, and exits.

| Event               | Icon        | State                                       |
| ------------------- | ----------- | ------------------------------------------- |
| `SessionStart`      | `😴`        | Idle                                        |
| `UserPromptSubmit`  | `🧑‍🍳`        | Processing                                  |
| `PreToolUse`        | `🧑‍🍳`        | Processing                                  |
| `PostToolUse`       | `🧑‍🍳`        | Processing                                  |
| `Stop`              | `😴`        | Idle                                        |
| `PermissionRequest` | `👀`        | Needs attention                             |
| `Notification`      | `👀`        | Needs attention                             |
| `SessionEnd`        | _(removed)_ | Restores the pre-session window name        |

### Window names

The text before the icon is the **Claude session title** — whatever you set with `/rename` — whenever tmux can see it. Otherwise the window keeps its own name.

When the session ends, the window name it had beforehand is put back.

Your `automatic-rename` setting is never modified, in either direction.

## Customization

### Switch icon themes

Use the built-in skill from inside Claude Code:

```
/tmux-icons              # list available themes
/tmux-icons emoji        # switch to emoji (default)
/tmux-icons nerd-font    # switch to Nerd Font icons
/tmux-icons minimal      # switch to plain text indicators
```

Changes take effect immediately on the next lifecycle event — no restart needed.

### Override a single icon

```
/tmux-icons set attention !!
```

### Create a custom theme

```
/tmux-icons create my-theme
```

### Bundled themes

| Theme       | Idle | Processing | Attention | Notes                      |
| ----------- | ---- | ---------- | --------- | -------------------------- |
| `emoji`     | 😴   | 🧑‍🍳         | 👀        | Default, works everywhere  |
| `nerd-font` | 󰒲    | 󰑮          | 󰂞         | Requires a patched font    |
| `minimal`   | zzz  | ...        | (!)       | Plain text, no font needed |

### Manual config

The active icon set is stored in `config/active.conf` as simple key=value pairs:

```
idle=😴
processing=🧑‍🍳
attention=👀
```

Theme presets live in `config/themes/*.json`.

### Keep your own window names

To ignore the Claude session title and always use the window's own name, add to `.tmux.conf`:

```tmux
set -g @claude_tmux_status_title off
```

Set it per-window with `set -w` instead.

## License

[MIT](LICENSE) © Zaid Alsaheb
