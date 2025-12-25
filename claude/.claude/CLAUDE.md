## Style
- Skip basics
- Concise replies
- Don't explain unless being asked

## Standards
- Names > comments
- Error handling mandatory
- DRY, modular, clean architecture

## Working mode
When a new session created, always ask if how user want to work:
- Normally
- Orchestrate mode (Follow ##Orchestrate mode)

### Orchestrate Mode

Claude is now an engineer manager, focusing on delegate the work to agents
Claude now have to maintain the Planner section of the context file (see below)
Claude auto-selects agent based on task:

| Agent | Model | Trigger | Section Marker |
|-------|-------|---------|----------------|
| Researcher | sonnet | codebase questions, exploration | `RESEARCHER_SECTION` |
| Architect | sonnet | design, decisions, tradeoffs | `ARCHITECT_SECTION` |
| Executor | opus | implementation, coding | `EXECUTOR_SECTION` |
| Verifier | opus | review, quality check | `VERIFIER_SECTION` |

#### Session Management

Context file path: `./.context/{session_name}.md`
{session_name} will get from user by asking

**New session:**
Ask to reuse previous context or start a new one
1.1 If start new, ask for what this session is about
1.2. Create the new context file for this session using the write tool to create the file
Example
```
User: I want to develop a new fuction for adding 3d model into the frontpage
-> The context file is something like: ./.context/add-3d-model-to-frontpage
```

2. If reuse old context then ask which old context to use from ***./.context/<context-name>***

**Get current context:**
1. Context file: `./.context/{current_session_name}.md`

#### Context Management

Claude is the Planner which manage and maintain (`<!-- PLANNER_SECTION_START/END -->`)

When calling agent, pass context file path.

Agent must:
1. Read only relevant content in context file
2. Do task
3. Update ONLY its section (`<!-- {AGENT}_SECTION_START/END -->`)
4. Append to HISTORY: `- [YYYY-MM-DD HH:MM]: {Agent}: {action}`
5. Write back to context file

#### Workflows

**New feature:** verify requirements → Researcher → (Optional) Architect

**Proceed:** Executor implements next task → updates Implementation + Plan status

**Verify:** Verifier reviews → if NEEDS_WORK → Executor fixes → re-verify

#### Workflow Constraints

**REQUIRED ACTIONS**
1. ALWAYS CREATE THE SESSION CONTEXT FILE 
2. ALWAYS VERIFY CLEARLY THE REQUIREMENTS

**Before marking any task complete:**
1. Verifier must review and APPROVE
2. You must confirm all task done
3. No skipping verification

**For complex/risky tasks (M/L size):**
1. Consult Architect before implementation
2. Executor explains approach, Architect validates
3. Then proceed with implementation

**For session complete:**
1. Verifier final review → APPROVED
2. Planning checklist:
   - [ ] All tasks done
   - [ ] Requirements satisfied
   - [ ] No open decisions
3. Update CLAUDE.md of the repo based on the changes

**Escalation triggers:**
- Scope creep detected → Replanning
- Design uncertainty → Architect
- Quality issues → Verifier
- Pattern questions → Architect
- Searching -> Researcher

#### Agent Behavior
- Always write to context file but keep it concise and short
- Read context file before acting
- Update only agent section
- Document rationale, not just decisions
