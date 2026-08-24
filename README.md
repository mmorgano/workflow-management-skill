# skill-workflow-management

A portable Kiro skill for structured daily work sessions, task tracking, optional
sprints, and safe session archival. It is intentionally project-agnostic: choose
your own context directory during setup and adapt any issue-tracker conventions
to your team.

## What it does

This skill teaches Kiro a **structured daily workflow management method**. When activated, Kiro knows how to:

- Open and close **daily sessions** (a work diary with decisions, blockers, next steps)
- Manage **sprints** (optional, configurable duration) with tickets and technical tasks
- Create and track **numbered tasks** with step-by-step execution plans
- Maintain a **global RECAP** (single source of truth for what's open/closed)
- **Compact old sessions** automatically (archive + zip, configurable retention)
- Guarantee **continuity across sessions** — each new conversation picks up exactly where the last one left off

The result: no context lost between sessions, full audit trail of decisions, and a repeatable workflow that reduces cognitive load.

## Prerequisites

- **Kiro** with skill support (`~/.kiro/skills/` directory)
- An `ai-context/` directory in your project (see Setup section)
- Basic familiarity with bash terminal
- `python3` available (for config file parsing in compaction script)
- `zip` available (for session archival)
- `unzip` available (to verify archives before originals are touched)

The supplied scripts target Bash on Linux/macOS. On Windows, run them from a
compatible Unix environment such as WSL, Git Bash, or a container.

## Setup

For a ready-made starting structure, see [`examples/basic-ai-context`](examples/basic-ai-context).

### Quick start (interactive wizard)

```bash
~/.kiro/skills/skill-workflow-management/setup-skills.sh
```

The wizard will ask you:
1. **AI_CONTEXT_ROOT** — where session/task/sprint files are stored
2. **Sprint management** — enable/disable, and if enabled: duration in weeks
3. **Session compaction** — enable/disable, retention period, grouping method

Configuration is saved to `<AI_CONTEXT_ROOT>/.workflow-config.json` and used by Kiro at session start. The wizard also stores only a local pointer to that context so the compaction command can be invoked without an explicit path.

### Non-interactive (path only, backward compatible)

```bash
~/.kiro/skills/skill-workflow-management/setup-skills.sh --path /absolute/path/to/ai-context
```

### Manual installation

If you're installing from a fresh clone:

```bash
# 1. Copy skill to global location
cp -r /path/to/skill-workflow-management ~/.kiro/skills/skill-workflow-management

# 2. Make scripts executable
chmod +x ~/.kiro/skills/skill-workflow-management/setup-skills.sh
chmod +x ~/.kiro/skills/skill-workflow-management/compact-sessions.sh

# 3. Run the wizard
~/.kiro/skills/skill-workflow-management/setup-skills.sh
```

### Bootstrap initial files (first time only)

After running the wizard, create the core files:

```bash
AI_CTX="/path/to/your/ai-context"  # Use the path you chose in the wizard

# RECAP — global list of open items
cat > "$AI_CTX/RECAP.md" << 'EOF'
# Recap — Open items

## Area 1

| Ticket | Description | Status | Notes |
|--------|-------------|--------|-------|

EOF

# LAST_SESSION — pointer to the last session
cat > "$AI_CTX/LAST_SESSION.md" << 'EOF'
# Last session

- **Date**: —
- **File**: —
- **Branch**: —
- **Status**: First session to be started
- **Next**: —
EOF

# Task INDEX — numbering registry
cat > "$AI_CTX/tasks/INDEX.md" << 'EOF'
# Task Index

Next available number: 1
EOF
```

## Configuration

The wizard creates `.workflow-config.json` in your AI_CONTEXT_ROOT:

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

| Setting | Values | Description |
|---------|--------|-------------|
| `sprint.enabled` | `true` / `false` | Whether sprints are used |
| `sprint.duration_weeks` | 1–6 | Sprint length |
| `compaction.enabled` | `true` / `false` | Whether old sessions are archived |
| `compaction.retention_days` | 7–365 | Days to keep sessions unarchived |
| `compaction.group_by` | `"month"` / `"sprint"` | How archived sessions are grouped |

You can edit this file directly or re-run the wizard.

## Session compaction

Over time, daily session files accumulate. Compaction keeps the `sessions/` directory lean while preserving full history.

> **Important:** a non-dry-run compaction verifies the ZIP and then moves the
> original files into `sessions/archive/originals/`. Use `--delete-originals`
> only when you deliberately want to remove them after that verification.

### What happens

- Session files **older than retention_days** are grouped (by month or sprint)
- For each group: a summary `.md` + a `.zip` of originals is created in `sessions/archive/`
- Original files are moved to `sessions/archive/originals/` by default; they
  are deleted only with the explicit `--delete-originals` option

### How to trigger

**Option 1 — AI-prompted:** At session start, Kiro checks if files exceed the threshold and offers to compact.

**Option 2 — Manual script:**

```bash
# Preview what would be compacted (no changes)
~/.kiro/skills/skill-workflow-management/compact-sessions.sh --dry-run

# Run compaction
~/.kiro/skills/skill-workflow-management/compact-sessions.sh

# With explicit path
~/.kiro/skills/skill-workflow-management/compact-sessions.sh /path/to/ai-context
```

### Archive structure

```
sessions/
├── SESSION_2026-08-20.md      # Recent — kept
├── SESSION_2026-08-21.md      # Recent — kept
└── archive/
    ├── 2026-06.md             # Summary table for June 2026
    ├── 2026-06.zip            # Original June session files
    ├── 2026-07.md             # Summary table for July 2026
    ├── 2026-07.zip            # Original July session files
    └── originals/              # Recoverable source files, by archive group
```

## Verifying it works

After setup, open a Kiro chat and type:

> "let's start the work session"

Kiro should:
1. ✅ Check the date with `date`
2. ✅ Read `.workflow-config.json` for active features
3. ✅ Read `RECAP.md` and `LAST_SESSION.md`
4. ✅ Create (or open) the session file `sessions/SESSION_YYYY-MM-DD.md`
5. ✅ Check for compaction opportunities (if enabled)
6. ✅ Show you a summary: open tasks, blockers, next steps (+ sprint if enabled)

**Troubleshooting:**
- Kiro can't find files → check `grep "AI_CONTEXT_ROOT" ~/.kiro/skills/skill-workflow-management/SKILL.md`
- Session file not created → verify the `sessions/` directory exists
- Skill not activated → verify the folder is in `~/.kiro/skills/`
- Compaction not working → check `python3` and `zip` are available

## Basic commands (what to ask Kiro)

| What you want | What to say |
|---------------|-------------|
| Open the daily session | "let's start the session" / "open session" |
| Close the session | "close the session" |
| Create a task | "create a task for [description]" |
| See open tasks | "show me open tasks" / "what's in the RECAP?" |
| Update a task status | "task #N is completed" |
| Create a focus file | "create a focus on [topic]" |
| Plan the sprint | "let's plan the next sprint" |
| Compact old sessions | "compact sessions" / "archive old sessions" |
| See the summary | "current status" / "recap" |

No rigid commands needed — Kiro interprets your intent and applies the skill's conventions.

## Directory structure

```
ai-context/
├── .workflow-config.json        # Runtime config (sprint, compaction settings)
├── CONVENTIONS.md               # Rules for what goes where
├── RECAP.md                     # Global task list — source of truth
├── LAST_SESSION.md              # Pointer to the last session
├── sessions/
│   ├── SESSION_YYYY-MM-DD.md    # Daily work diary
│   └── archive/                 # Compacted old sessions
│       ├── YYYY-MM.md           # Monthly summary
│       └── YYYY-MM.zip          # Original files
├── sprints/                     # (only if sprint.enabled = true)
│   └── SPRINT_YYYY-MM-DD.md    # Sprint file
├── tasks/
│   ├── INDEX.md                 # Numbering registry
│   ├── todo/
│   │   └── NN-slug.md           # Active tasks
│   └── done/
│       └── NN-slug.md           # Completed tasks
├── focus/
│   └── <slug>.md                # Multi-session deep-dive docs
├── roadmap/
│   └── <project>.md             # Medium-term vision
└── meetings/
    └── YYYY-MM-DD-<topic>.md    # Meeting notes
```

## Skill files

| File | Purpose |
|------|---------|
| `SKILL.md` | Main skill document (loaded by Kiro on activation) |
| `setup-skills.sh` | Interactive configuration wizard |
| `compact-sessions.sh` | Session archival script (manual trigger) |
| `README.md` | This file |

## Tips for daily use

1. **Always open a session at the start of the day** — even if you think you'll do little. Continuity is the system's main value.

2. **Close the session at end of day** — make sure "next steps" are clear. They're the first thing you'll read tomorrow.

3. **Use tasks for work > 30 minutes** — the step-by-step plan prevents losing track after interruptions.

4. **The RECAP is your dashboard** — keep it updated (Kiro does it for you).

5. **Don't duplicate information** — RECAP for status, tasks for plans, sessions for diary.

6. **Use focus files for complex topics** spanning multiple sessions.

7. **Sprints are optional** — if you don't work with formal sprints, disable them in the wizard. The system works perfectly without them.

8. **Let compaction work for you** — once configured, you don't need to think about old session files piling up. The system handles it.

9. **Have Kiro read the recap when it starts** — the files are its memory across sessions.

## Sharing with teammates

1. Copy the `skill-workflow-management/` folder to their `~/.kiro/skills/`
2. Have them run `setup-skills.sh` (the wizard guides everything)
3. Done — each user gets their own configuration

Each user has their own session/task/RECAP files. The skill is shared, the data is personal.

## Before publishing a fork

- Run `tests/smoke-test.sh` in a Bash environment with Python, `zip`, and `unzip`.
- Confirm no personal context directory or runtime configuration is committed.
- Review Git author metadata: commit author names and email addresses are public with the history.

## License

MIT — see LICENSE file.
