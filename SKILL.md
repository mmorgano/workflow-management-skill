---
name: skill-workflow-management
description: Personal development methodology — sessions, sprints, tasks, RECAP
---

# Workflow Management — Personal Development Methodology

## Configuration

> **AI_CONTEXT_ROOT**: `/path/to/your/ai-context`
>
> All paths in this skill are relative to this root unless stated otherwise.
> To customize for your environment, run the interactive wizard:
> ```bash
> ~/.kiro/skills/skill-workflow-management/setup-skills.sh
> ```

A structured methodology for managing daily work sessions, sprints, tasks, and project knowledge using AI-assisted context files.

## Overview

This skill defines a complete personal project management system built around:
- **Daily sessions** — timestamped work logs with structured sections
- **Sprints** (optional) — time-boxed planning cycles with ticket tracking
- **Tasks** — numbered, self-contained work items with execution plans
- **RECAP** — global source of truth for open/closed items
- **Focus files** — deep-dive documents for complex multi-session topics
- **Session compaction** (optional) — automatic archival of old session files

The system is designed to maintain continuity across AI sessions, prevent context loss, and provide a clear audit trail of decisions and progress.

## Runtime Configuration

Configuration is stored in `AI_CONTEXT_ROOT/.workflow-config.json`:

```json
{
  "version": "1.0.0",
  "ai_context_root": "/absolute/path/to/ai-context",
  "sprint": {
    "enabled": true,
    "duration_weeks": 2
  },
  "compaction": {
    "enabled": true,
    "retention_days": 30,
    "group_by": "month"
  }
}
```

### Configuration Fields

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `sprint.enabled` | bool | `true` | Enable sprint management |
| `sprint.duration_weeks` | int | `2` | Sprint length in weeks (1–6) |
| `compaction.enabled` | bool | `true` | Enable session file archival |
| `compaction.retention_days` | int | `30` | Days to keep session files uncompacted |
| `compaction.group_by` | string | `"month"` | Grouping for archives: `"month"` or `"sprint"` |

When starting a session, Kiro MUST read `.workflow-config.json` to determine which features are active.

## When to Activate

Activate this skill when:
- Starting a new work session (session file creation)
- Planning or reviewing sprints (if enabled)
- Creating, managing, or closing tasks
- Updating project status (RECAP, LAST_SESSION)
- Setting up the workflow system in a new project

## Directory Structure

All paths below are relative to `AI_CONTEXT_ROOT`.

```
ai-context/
├── .workflow-config.json        # Runtime configuration (created by setup wizard)
├── CONVENTIONS.md               # Rules for what goes where
├── RECAP.md                     # Global task list (open/closed) — single source of truth
├── LAST_SESSION.md              # Pointer to last session (synthetic summary)
├── sessions/
│   ├── SESSION_YYYY-MM-DD.md    # Daily work diary
│   └── archive/                 # Compacted sessions (monthly/sprint summaries + zip)
│       ├── YYYY-MM.md           # Summary table for archived month
│       └── YYYY-MM.zip          # Original session files
├── sprints/                     # (only if sprint.enabled = true)
│   └── SPRINT_YYYY-MM-DD.md    # Sprint file (date = sprint start)
├── tasks/
│   ├── INDEX.md                 # Numbering registry (source of truth for next number)
│   ├── todo/
│   │   └── NN-slug.md           # Active tasks
│   └── done/
│       └── NN-slug.md           # Completed tasks
├── focus/
│   └── <slug>.md                # Complex multi-session topics
├── roadmap/
│   └── <project>.md             # Medium-term vision per project
└── meetings/
    └── YYYY-MM-DD-<topic>.md    # Meeting notes
```

## Session Lifecycle

### Start of Session

1. Verify real date with `date` command
2. Read `.workflow-config.json` to determine active features
3. Read: `RECAP.md`, `LAST_SESSION.md`, current sprint file (if sprints enabled)
4. Check if `sessions/SESSION_YYYY-MM-DD.md` exists — create if missing
5. **If compaction is enabled**: check if any session files exceed retention threshold. If so, inform user and offer to run compaction.
6. Display structured summary: open tasks, blockers, next steps (+ sprint info if enabled)

### During Session

- Update session file with work performed
- Update RECAP.md when task statuses change
- Update sprint file when ticket statuses change (if sprints enabled)

### End of Session

1. Update session file (work done, decisions, next steps, timesheet)
2. Update `LAST_SESSION.md` as synthetic pointer
3. Update `RECAP.md` if any task changed status

## Session File Template

### With sprints enabled:

```markdown
# Session — YYYY-MM-DD

## Current sprint
Sprint N — from DD/MM/YYYY to DD/MM/YYYY

## Work done
-

## Decisions made
-

## Problems / blockers
-

## Active focus
-

## Next steps
-

## Timesheet
| Start | End | Duration | Activity |
|-------|-----|----------|----------|
```

### Without sprints:

```markdown
# Session — YYYY-MM-DD

## Work done
-

## Decisions made
-

## Problems / blockers
-

## Active focus
-

## Next steps
-

## Timesheet
| Start | End | Duration | Activity |
|-------|-----|----------|----------|
```

## Session Compaction

When `compaction.enabled = true`, the system archives session files older than `retention_days`.

### How it works

1. Files in `sessions/` older than the **effective retention** threshold are identified
2. They are grouped by `group_by` setting (month or sprint)
3. For each group, the system creates:
   - `sessions/archive/<key>.md` — summary table with date + one-liner per session
   - `sessions/archive/<key>.zip` — zip of the original `.md` files
4. Original files are removed from `sessions/`

### Safety buffer

The cutoff date is **never** just `retention_days` — a safety buffer protects active work:

- **With sprints enabled**: buffer = `2 × sprint_duration_weeks × 7` (current + previous sprint)
- **Without sprints**: minimum floor of 25 days
- **Effective retention** = `max(retention_days, buffer, 25)`

Example: sprint = 2 weeks, retention = 30 days → buffer = 28, effective = 30.
Example: sprint = 3 weeks, retention = 30 days → buffer = 42, effective = 42.

This ensures the compaction never touches files belonging to the current or previous sprint, even on the first day of a new month.

### Archive summary format

```markdown
# Session Archive — 2026-07

| Date | Summary |
|------|---------|
| 2026-07-01 | Task #25 completato, fix pipeline MUFA |
| 2026-07-02 | Sprint planning and pull-request review |
| ... | ... |

---
Original files archived in: 2026-07.zip
```

### Triggering compaction

Two methods:
1. **AI-prompted**: At session start, if files exceed threshold, Kiro informs the user and offers to compact
2. **Manual script**: `~/.kiro/skills/skill-workflow-management/compact-sessions.sh [--dry-run]`

### Rules
- Never compact today's session file
- Never compact files within the retention window
- The `--dry-run` flag shows what would be archived without making changes
- Archived summaries are read-only references — never modify them

## Sprint Management (Optional)

Sprints are **only active when `sprint.enabled = true`** in config.

When sprints are disabled:
- No `sprints/` directory is needed
- Session files omit the "Current sprint" section
- RECAP.md ticket tables omit the "Sprint" column
- The AI does not ask about or reference sprints

When sprints are enabled:
- Sprint duration is `sprint.duration_weeks` (default 2)
- All sprint behaviors described below apply

### Sprint File Template

```markdown
# Sprint — DD/MM/YYYY → DD/MM/YYYY

## Goal
<One-line sprint goal>

## Sprint tickets

| Ticket | Domain | Description | Assignee | Status | Notes |
|--------|--------|-------------|----------|--------|-------|

## Technical tasks (non-ticket) — sprint priority

| Task | Area | Priority |
|------|------|----------|

## Blockers / risks

| Blocker | Impact | Action |
|---------|--------|--------|

## Decisions made
-

## Notes
-
```

### Sprint States
- ⬜ Todo / Draft / Open
- 🔄 In Progress / In corso / Review
- ⏸ Need Info / Bloccato
- ✅ Done / Closed
- ❌ Cancelled

## Task Management

### INDEX.md Rules
- One number = one task. Never reused.
- Read `AI_CONTEXT_ROOT/tasks/INDEX.md` BEFORE creating a task to get next number
- Update INDEX.md AFTER creating a task (register + increment)
- Never assume number from filesystem — INDEX.md is source of truth

### Task File Template

```markdown
# Task: <Title>

## Related ticket
PROJ-XXXX / TBD

## Goal
<One sentence describing the outcome>

## Current state
<Context, current architecture, what exists>

## Impact analysis
### Files to CREATE / MODIFY / NOT touched
### Dependencies
### Risks

## Execution plan
| Step | Action | Status | Notes |
|------|--------|--------|-------|
| 0 | Safety: tag/backup | ⬜ | |
| 1 | ... | ⬜ | |

## Estimated duration
## Success criteria
## References
```

### Task Rules
- Step 0 is ALWAYS a safety checkpoint (git tag or backup)
- Execution plan requires explicit approval for non-trivial tasks
- Update Status column during execution: ⬜ → 🔄 → ✅
- Move file from `todo/` to `done/` on completion

## RECAP.md

- Located at `AI_CONTEXT_ROOT/RECAP.md`
- Global task list grouped by domain/area
- Checkbox `[x]` / `[ ]` for status
- Updated DURING the session when tasks change status (not just at end)
- Single source of truth for "what is open"

## LAST_SESSION.md

Located at `AI_CONTEXT_ROOT/LAST_SESSION.md`. Synthetic pointer to the last session — kept minimal:

```markdown
# Last session

- **Date**: YYYY-MM-DD
- **File**: sessions/SESSION_YYYY-MM-DD.md
- **Branch**: <active branches>
- **Status**: <one-line summary>
- **Next**: <priority next step>
```

Updated AFTER the session file, never before.

## Focus Files

For complex multi-session topics:

```markdown
# Focus — <Title>

## Context and goal
## Known constraints and challenges
## Proposed architecture / approach
## Work sessions
### YYYY-MM-DD — <short title>
## Attempts and results
## Decisions made
## Open problems
## References
```

## Language Convention

By default, all skill files, templates, and documentation use **English**. Users may customize session/task/focus files to their preferred language — the system is language-agnostic for content.

Suggested convention for multilingual teams:

| Context | Language |
|---------|----------|
| Code, comments, docstrings | English |
| Official docs (README, docs/) | English |
| Commit messages, issue trackers | English |
| Sessions, RECAP, tasks, focus | Team choice (any language) |

## Issue Tracker Integration (optional)

If using an issue tracker (JIRA, GitHub Issues, GitLab, etc.):

- Reference tickets in tasks and sprint files using the tracker's key format
- Transitions: verify available transitions before changing status (ask before executing)
- Never close/transition a ticket without explicit user confirmation
- Comments: use the tracker's mention syntax for notifications

Customize this section for your team's specific tracker and conventions.

## Key Principles

1. **Compiled Truth pattern**: top of document = current state (rewritten when it changes); bottom/timeline = historical events (append-only, never modified)
2. **Single source of truth**: RECAP for open items, INDEX.md for task numbers, sprint file for ticket states (if enabled)
3. **Verify before asserting**: always `date` for timestamps, `grep -n` for line numbers, re-read before modifying
4. **Continuity across sessions**: LAST_SESSION.md + session file structure ensures no context is lost between AI conversations
5. **Configuration-driven behavior**: always check `.workflow-config.json` before assuming sprint or compaction features are active
