# Claude Agent Skills

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A collection of custom hooks that extend [Claude Code](https://docs.anthropic.com/en/docs/claude-code) with real-time notification capabilities. Receive Slack and LINE messages when your AI agent starts, finishes a task, or needs your approval.

---

## Table of Contents

- [Overview](#overview)
- [Available Skills](#available-skills)
- [Quick Start](#quick-start)
- [How Claude Code Hooks Work](#how-claude-code-hooks-work)
- [Repository Structure](#repository-structure)
- [Contributing](#contributing)
- [License](#license)

---

## Overview

When running Claude Code as an autonomous agent, long-running tasks can complete while you are away from the terminal. These skills solve that problem by sending push notifications to Slack or LINE at key lifecycle events:

- **Task completion** -- Get notified the moment a task finishes so you can review the results.
- **Approval required** -- Receive an alert when the agent is waiting for your input before proceeding.
- **Toggle on/off** -- Enable or disable notifications without modifying configuration files.

All skills are implemented as stateless Bash scripts using `curl`, making them lightweight and dependency-free beyond a standard Unix environment.

---

## Available Skills

| Skill | Description | Integration |
|-------|-------------|-------------|
| [slack-notify](./slack-notify/) | Sends Slack notifications on task completion and approval requests | Slack Incoming Webhooks |
| [line-notify](./line-notify/) | Sends LINE push notifications on task completion and approval requests | LINE Messaging API |

Each skill directory contains:

| File | Purpose |
|------|---------|
| `*-notify.sh` | Main notification script (fires on Stop event) |
| `*-notify-waiting.sh` | Waiting/approval notification script (fires on Stop event when waiting) |
| `*-notify-toggle.sh` | Toggle script to enable or disable notifications |
| `README.md` | Detailed setup and configuration instructions |

---

## Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/sohei-t/claude-agent-skills.git
cd claude-agent-skills
```

### 2. Choose a Skill

Navigate to the skill directory and follow its README for setup:

```bash
cd slack-notify   # or line-notify
```

### 3. Configure Claude Code Hooks

Add the hook scripts to your Claude Code settings at `~/.claude/settings.json`:

```json
{
  "hooks": {
    "Stop": [
      {
        "type": "command",
        "command": "/path/to/claude-agent-skills/slack-notify/slack-notify.sh"
      }
    ]
  }
}
```

Refer to each skill's README for the complete configuration, including webhook URLs and API tokens.

---

## How Claude Code Hooks Work

Claude Code supports lifecycle hooks that execute arbitrary commands at specific agent events:

| Event | When It Fires |
|-------|---------------|
| `Start` | Agent session begins |
| `Stop` | Agent completes a task or pauses for input |

Hooks are configured in `~/.claude/settings.json` and run as child processes of the Claude Code CLI. The notification scripts in this repository are designed to be registered as `Stop` event hooks.

For full documentation, see the [Claude Code hooks reference](https://docs.anthropic.com/en/docs/claude-code).

---

## Repository Structure

```
claude-agent-skills/
  README.md               # This file
  LICENSE                 # MIT License
  slack-notify/           # Slack notification skill
    README.md             # Setup instructions
    slack-notify.sh       # Task completion notification
    slack-notify-waiting.sh   # Approval request notification
    slack-notify-toggle.sh    # Enable/disable toggle
  line-notify/            # LINE notification skill
    README.md             # Setup instructions
    line-notify.sh        # Task completion notification
    line-notify-waiting.sh    # Approval request notification
    line-notify-toggle.sh     # Enable/disable toggle
```

---

## Contributing

Contributions are welcome. To add a new skill:

1. Create a new directory with a descriptive name
2. Include the notification scripts and a `README.md` with setup instructions
3. Open a pull request describing the integration

---

## License

[MIT License](./LICENSE)
