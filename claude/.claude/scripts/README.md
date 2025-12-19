# Session Management Helper Scripts

This directory contains simple helper scripts for Claude's orchestrator command.

## session.sh

A minimal session management script for the Claude orchestrator. This script handles basic session operations like creating, listing, and switching sessions.

### Purpose

The `session.sh` script serves as a helper for the `/o` command in Claude Code, handling only the session management aspects:

- Creating new session directories
- Listing available sessions
- Switching between sessions
- Showing current active session

### Usage

This script is used internally by the `/o` command in Claude Code, but can also be used directly:

```bash
# Create a new session
./session.sh new feature-name

# List all sessions
./session.sh list

# Show current session
./session.sh current

# Switch to another session
./session.sh switch 20251219-143932-feature-name
```

### Integration with Claude

When you use the `/o` command in Claude Code, it uses this script to manage session state, while Claude handles the interpretation and execution of commands based on the definition in `.claude/commands/o.md`.

The script follows a simple design principle - it does one thing (session management) and does it well.