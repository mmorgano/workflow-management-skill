# Workflow Management — Full Conventions

## Session Rules (`sessions/SESSION_YYYY-MM-DD.md`)

- One file per working day, centralized (no per-domain copies)
- Contains ALL work of the day: code, decisions, reasoning, problems
- Written in **Italian** (code/commands in English)
- At session start: verify if file exists, create if missing
- Updated during session via checkpoints
- Saved at session end

### First-Use Initialization

A configured but empty context is valid. On the first session start, create
missing records without overwriting anything that already exists:

1. Create `RECAP.md` with this minimal content:
   ```markdown
   # Recap — Open items

   ## General

   | Ticket | Description | Status | Notes |
   |--------|-------------|--------|-------|
   ```
2. Create `tasks/INDEX.md` with:
   ```markdown
   # Task Index

   Next available number: 1
   ```
3. If sprints are enabled and no sprint covers the current date, create
   `sprints/SPRINT_YYYY-MM-DD.md`. Use the current date as the first sprint's
   start and the configured duration to calculate its inclusive end date.
4. Create `sessions/SESSION_YYYY-MM-DD.md` with sections for work done,
   decisions, blockers, active focus, next steps, and a timesheet. Include the
   sprint identifier and period when sprints are enabled.

Do not create `LAST_SESSION.md` during first-session startup. Its absence means
there is no previous session. Create it when the first session is closed.

### Session Start Procedure

1. Verify real date with `date` command (never guess)
2. Resolve `AI_CONTEXT_ROOT` and read `.workflow-config.json`
3. Perform first-use initialization for missing records
4. Read `RECAP.md`, `LAST_SESSION.md` when present, and the current sprint file
5. Check if `sessions/SESSION_YYYY-MM-DD.md` exists — create if missing
6. Display structured summary: sprint, open tasks, blockers, next steps

### Session Close Procedure

1. Finalize the current session record, including next steps and timesheet
2. Create or update `LAST_SESSION.md`
3. Update `RECAP.md`
4. Update the current sprint when its tickets, blockers, or decisions changed

### LAST_SESSION.md

- Only a synthetic pointer — detailed content lives in session file
- Updated AFTER the session file, never before
- Missing before the first close is a valid state
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
- Created automatically with next number `1` during the first session start
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
