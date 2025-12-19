---
name: o
description: Enter orchestrate mode for feature development
---

# /o Command

Enter orchestrate mode. Claude becomes engineer manager, delegates to agents.

## Usage

| Command | Action |
|---------|--------|
| `/o status` | Show current session state |
| `/o proceed` | Execute next task |
| `/o verify` | Quality check |
| `/o end` | End Orchestrate session |

## On Trigger
1. Follow Orchestrate Mode workflow from CLAUDE.md
2. All subsequent messages route through orchestrator until `/o end`

## Invalid/Empty Command
```
Usage: /o <command>

Commands:
  status      Current session state
  proceed     Execute next task
  verify      Quality check
  end         Finish session
```
