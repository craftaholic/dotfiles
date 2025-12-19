---
name: o
description: Orchestrator for feature implementation with session management
---

# Orchestrator

Single interface for feature work. Manages agents and sessions.

## Commands
```
USAGE: /o COMMAND [ARGUMENTS]

A session orchestrator for managing feature development workflow.

Session Management:
  new FEATURE_NAME    Create a new session for the specified feature
  sessions            List all available sessions
  switch SESSION_ID   Switch to an existing session

Workflow Control:
  proceed             Execute the next task in the current session
  verify              Perform quality check on implemented changes
  complete            Mark current session as completed and archive

Status & Information:
  status              Show current session status and next steps
  help                Show this help message

Examples:
  /o new add-search-feature    Create new session for adding search feature
  /o status                    Show current session status
  /o proceed                   Execute next planned task
```

## How It Works

When you use the `/o` command, it will:

1. **Create/manage sessions** using the helper script at `.claude/scripts/session.sh`
2. **Process your request** based on the command and arguments
3. **Present formatted output** with clear, helpful information

### Error Handling

If you enter an invalid command or syntax, you'll see helpful error messages:

```
Error: Unknown command "statsus"
USAGE: /o COMMAND [ARGUMENTS]
Run '/o help' to see available commands.
Did you mean '/o status'?
```

Or for missing arguments:

```
Error: Missing required argument for command "new"
USAGE: /o new FEATURE_NAME
Example: /o new add-search-feature
```

### Command Behavior

- **new**: Creates directories, files, and initiates the workflow
- **status**: Shows current session state and progress
- **proceed**: Advances to the next task in the plan
- **verify**: Performs quality check on implementation
- **complete**: Archives the session and cleans up

## Session Management
- On "new FEATURE_NAME" → Create session: .claude/{timestamp}-{feature-slug}/handoff/
- Session ID format: YYYYMMDD-HHMMSS-{feature-slug}
- Store session path in .claude/current-session

## Session Structure
```
.claude/
├── current-session              # Points to active session
└── 20241219-143022-add-dlq/
    └── handoff/
        ├── context.md           # Feature overview, status
        ├── research.md          # Researcher output
        ├── architecture.md      # Architect output
        ├── plan.md              # Planner output
        ├── changes.md           # Executor output
        └── review.md            # Verifier output
```

## Agents
- Researcher → explore codebase
- Architect → system design, decisions
- Planner → task breakdown
- Executor → implement
- Verifier → quality review

## Workflow Details

### Workflow: New Feature
1. Create session directory
2. Write session path to .claude/current-session
3. Invoke Researcher → save to handoff/research.md
4. Invoke Architect → save to handoff/architecture.md
5. Invoke Planner → save to handoff/plan.md
6. Update handoff/context.md with status
7. Present plan, ask for approval

### Workflow: Continue
1. Read .claude/current-session
2. Load handoff/context.md
3. Determine current state from plan.md
4. Resume from last incomplete task

### Workflow: Proceed
1. Read current task from plan.md
2. Invoke Executor for that task
3. Update changes.md
4. Mark task done in plan.md
5. Update context.md

### Workflow: Verify
1. Invoke Verifier
2. Save to review.md
3. If APPROVED → ready to complete
4. If NEEDS_WORK → show issues -> invoke executor to update

### Workflow: Complete
1. Mark session complete in context.md
2. Clear .claude/current-session
3. Session dir remains for history

## Command Error Handling

### Error Types
- **Unknown command**: When command doesn't exist
- **Missing argument**: When required argument is missing
- **Invalid session**: When specified session doesn't exist
- **No active session**: When command requires active session

### Error Messages
```
Error: Unknown command "INVALID_COMMAND"
USAGE: /o COMMAND [ARGUMENTS]
Run '/o help' to see available commands.

Error: Missing required argument for command "new"
USAGE: /o new FEATURE_NAME
Example: /o new add-search-feature

Error: No active session
Run '/o new FEATURE_NAME' to create a session or '/o switch SESSION_ID' to switch to an existing one.
```

## Context File Format
```markdown
## Session
ID: 20241219-143022-add-dlq
Feature: Add SQS DLQ with alerting
Status: PLANNING | EXECUTING | VERIFYING | COMPLETE
Created: 2024-12-19 14:30:22

## Progress
- [x] Research
- [x] Architecture
- [x] Planning
- [ ] Task 1: Create DLQ stack
- [ ] Task 2: Add alerting
- [ ] Verify

## Decisions
- Use existing SNS topic
- 14d retention
```

## Behavior
- One voice (don't expose agent names)
- Ask only for decisions
- Update handoff files after each step
- Always show current session ID
- Provide helpful error messages
- Follow standard CLI patterns
