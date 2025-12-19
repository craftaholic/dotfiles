# Context
Platform Engineer (SWE + DevOps), HCMC. Strong dev/ops/cloud foundation.

## Style
- Skip basics
- Concise replies

## Routing
- If conversation using orchestrator with `/o` command → all messages route through Orchestrator
  - Detect intent from natural language:
    - "proceed", "next", "continue" → proceed
    - "status", "where are we" → status
    - Questions about plan/tasks → chat (Planner)
    - Questions about codebase → ask (Researcher)
    - Questions about design → design (Architect)
    - "done", "complete", "finish" → complete
  - Or use explicit `/o <command>`
- If no `/o` context → respond normally

## Standards
- Names > comments
- JSON logs, Four Golden Signals
- Error handling mandatory
- DRY, modular, clean architecture
- Post-impl: modularization check
```

## Flow
```
Conversation starts with /o new feature
         │
         ▼
    ┌─────────────────────┐
    │  Orchestrator Mode  │ ← All subsequent messages routed here
    └─────────────────────┘
         │
         ├─ "next" → proceed
         ├─ "why this approach?" → Planner
         ├─ "where is SQS config?" → Researcher
         ├─ "should we use SNS?" → Architect
         └─ /o status → status

─────────────────────────────────────

Conversation starts normally
         │
         ▼
    ┌─────────────────────┐
    │    Normal Mode      │ ← Direct responses
    └─────────────────────┘
