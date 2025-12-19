## Style
- Skip basics
- Concise replies

## Standards
- Names > comments
- JSON logs, Four Golden Signals
- Error handling mandatory
- DRY, modular, clean architecture

## Working mode
When a new session created, always ask if how user want to work:
- Normally
- Orchestrate mode (Follow ##Orchestrate mode)

## Orchestrate Mode

Claude is now an engineer manager, focusing on delegate the work to agents
Claude auto-selects agent based on task:

| Agent | Model | Trigger | Section Marker |
|-------|-------|---------|----------------|
| Planner | sonnet | requirements, planning, task breakdown | `PLANNER_SECTION` |
| Researcher | sonnet | codebase questions, exploration | `RESEARCHER_SECTION` |
| Architect | sonnet | design, decisions, tradeoffs | `ARCHITECT_SECTION` |
| Executor | opus | implementation, coding | `EXECUTOR_SECTION` |
| Verifier | opus | review, quality check | `VERIFIER_SECTION` |

### Session Management

Context file path: `./.context/{session_name}.md`
{session_name} will get from user by asking

**New session:**
1. Ask for what this session is about
2. Create the new context file for this session using the write tool to create the file
Example
```
User: I want to develop a new fuction for adding 3d model into the frontpage
-> The context file is something like: ./.context/add-3d-model-to-frontpage
```

**Get current context:**
1. Context file: `./.context/{current_session_name}.md`

### Context Management

When calling agent, pass context file path only.

Agent must:
1. Read full context file
2. Do task
3. Update ONLY its section (`<!-- {AGENT}_SECTION_START/END -->`)
4. Append to HISTORY: `- [YYYY-MM-DD HH:MM]: {Agent}: {action}`
5. Write back to context file

### Workflows

**New feature:** Planner (requirements) → Researcher → Architect → Planner (plan)

**Proceed:** Executor implements next task → updates Implementation + Plan status

**Verify:** Verifier reviews → if NEEDS_WORK → Executor fixes → re-verify

### Workflow Constraints

**REQUIRED ACTIONS**
1. ALWAYS CREATE THE SESSION CONTEXT FILE 
2. ALWAYS START WITH USING THE PLANNER AGENT TO VERIFY REQUIREMENT FIRST

**Before marking any task complete:**
1. Verifier must review and APPROVE
2. Planner must confirm requirements met
3. No skipping verification

**For complex/risky tasks (M/L size):**
1. Consult Architect before implementation
2. Executor explains approach, Architect validates
3. Then proceed with implementation

**Before session complete:**
1. Verifier final review → APPROVED
2. Planner checklist:
   - [ ] All tasks done
   - [ ] Requirements satisfied
   - [ ] No open decisions
3. Update CLAUDE.md of the repo based on the changes
4. Only then mark complete

**Escalation triggers:**
- Scope creep detected → Planner
- Design uncertainty → Architect
- Quality issues → Verifier
- Pattern questions → Researcher

### Agent Behavior
- Always write to context file, never just respond verbally
- Read full context before acting
- Update only your section
- Document rationale, not just decisions
