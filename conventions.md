# Workflow Management — Full Conventions

## Session Rules (`sessions/SESSION_YYYY-MM-DD.md`)

- One file per working day, centralized (no per-domain copies)
- Contains ALL work of the day: code, decisions, reasoning, problems
- Written in **Italian** (code/commands in English)
- At session start: verify if file exists, create if missing
- Updated during session via checkpoints
- Saved at session end

### Session Start Procedure

1. Verify real date with `date` command (never guess)
2. Read: `RECAP.md`, `LAST_SESSION.md`, current sprint file
3. Check if `sessions/SESSION_YYYY-MM-DD.md` exists — create if missing
4. Display structured summary: sprint, open tasks, blockers, next steps

### LAST_SESSION.md

- Only a synthetic pointer — detailed content lives in session file
- Updated AFTER the session file, never before
- Format:
  ```markdown
  # Ultima sessione
  - **Data**: YYYY-MM-DD
  - **File**: sessions/SESSION_YYYY-MM-DD.md
  - **Branch**: <active branches>
  - **Stato**: <one-line summary>
  - **Prossimo**: <priority next step>
  ```

## Sprint Rules (`sprints/SPRINT_YYYY-MM-DD.md`)

- One file per sprint (2 weeks), name = sprint start date
- Contains: objective, tickets with status, blockers, decisions
- Updated during session when ticket statuses change
- Closed at sprint end (creates next sprint file)

### Sprint States
- ⬜ Todo / Draft / Open
- 🔄 In Progress / In corso / Review
- ⏸ Need Info / Blocked
- ✅ Done / Closed
- ❌ Cancelled

## Task Rules (`tasks/{todo,done}/`)

### INDEX.md — Source of Truth
- One number = one task. Never reused.
- Read INDEX.md BEFORE creating a task to get next number
- Update INDEX.md AFTER creating a task (register + increment)
- Never assume number from filesystem

### Task Lifecycle
```
1. ANALYSIS   → understand problem, read code, identify impacts
2. PLAN       → task file with: objective, impacts, risks, execution plan
3. APPROVAL   → explicit user confirmation (never proceed without "ok"/"procedi")
4. EXECUTION  → step by step, updating status in plan
5. VERIFY     → green tests, pylint 10/10, smoke test
6. COMMIT     → only after green verification
```

### Task File Rules
- Step 0 is ALWAYS a safety checkpoint (git tag or backup)
- Execution plan requires explicit approval for non-trivial tasks
- Update Status column during execution: ⬜ → 🔄 → ✅
- Move file from `todo/` to `done/` on completion
- Naming: `NN-slug-descrittivo.md`

## RECAP.md

- Global task list grouped by domain/area
- Checkbox `[x]` / `[ ]` for status
- Updated DURING the session when tasks change (not just at end)
- Single source of truth for "what is open"

## Focus Files (`focus/<slug>.md`)

- One file per complex topic spanning multiple sessions
- Updated each session that works on the topic
- Session file always links active focus files
- Structure: Context → Constraints → Approach → Sessions → Decisions → Open problems

## Compiled Truth Pattern

Every technical document follows this principle:
- **Top**: current state (compiled truth — rewritten when it changes)
- **Bottom/Timeline**: historical events (append-only, never modified)

## Language Convention

| Context | Language |
|---------|----------|
| Chat, sessions, RECAP, focus, tasks | Italian |
| Code, comments, docstrings | English |
| Official docs (README, docs/) | English |
| Commit messages, issue trackers | English |
| Issue-tracker comments | English, using the format supported by the tracker |

## Mandatory Behavioral Rules

### Human-in-the-Loop (NEVER proceed without explicit confirmation)
- `git push --force`, `git reset --hard`
- Deleting multiple files/directories
- Production DB modifications, deploy to ACC/PROD
- Modifying `.env`, credentials, tokens
- Adding external dependencies

### Error Recovery
- Report exact error (command, exit code, stderr)
- Identify root cause BEFORE attempting fix
- Max 2 recovery approaches — if same approach fails twice, stop and explain
- NEVER retry silently

### Verification
- Before citing a line number: verify with grep/read
- Before modifying a file: re-read the section to change
- After incremental edits: re-read the result before proceeding
- If not verified: state it explicitly

### Scope Discipline
- Modify ONLY files related to the current task
- Do NOT refactor surrounding code unless explicitly asked
- Do NOT add features beyond what was requested
- If a prerequisite is missing: report it, do not implement it

## Git Conventions

- **Branch**: use the project's preferred naming convention (for example, `feature/issue-123`)
- **Commit**: use the project's preferred format — one logical change, tests included
- **Tag**: `<package>-v<version>`
- **Push**: always on branch, never on master directly
- **Feature branch**: deleted after merge (no-ff)
- **Deploy rule**: everything that gets deployed must be committed — deploy tool generates script from commits
