# Workflow Management Core

This document defines the platform-independent behavior of the workflow-management skill.
Agent adapters supply only installation details and agent-specific activation language.

## Shared contract

An adapter must instruct its agent to:

1. Resolve `<AI_CONTEXT_ROOT>` from an explicit user path, a workspace root
   named `ai-context` that contains `.workflow-config.json`, the user-local
   context pointer, or a `.workflow-config.json` in the current workspace.
   Do not substitute general workspace analysis for workflow initialization.
2. Read `<AI_CONTEXT_ROOT>/.workflow-config.json` before assuming that sprints
   or compaction are enabled.
3. At session start, initialize missing first-use records in a configured
   context, then read the recap, previous-session pointer, and current sprint.
4. Treat a missing `LAST_SESSION.md` as a normal first-session state. Create it
   only when a session is closed.
5. Use `tasks/INDEX.md` as the source of truth for task numbers.
6. Update session, RECAP, and sprint records as work changes.
7. Ask before destructive operations, external publication, or non-trivial
   execution plans.
8. Offer session compaction; never run it without user confirmation.

## Shared assets

- `setup-skills.sh` creates the configuration and context directory structure.
- `setup-skills.ps1` provides the same setup natively on Windows.
- `compact-sessions.sh` performs recoverable session archival.
- `conventions.md` contains the detailed workflow conventions.
- `examples/basic-ai-context/` provides a minimal starting context.

## Configuration and layout

The runtime file is `<AI_CONTEXT_ROOT>/.workflow-config.json`. It controls
whether sprints and compaction are active.

The setup scripts also write a user-local pointer named
`skill-workflow-management/context-path.json` under the platform configuration
directory. On Windows this is normally
`%USERPROFILE%\.config\skill-workflow-management\context-path.json`; on POSIX
systems it is normally
`${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management/context-path.json`.
An explicit path always takes precedence over the pointer.

When `ai-context` is added as a separate root in a multi-root workspace, its
own `.workflow-config.json` is a workspace-local, sandbox-friendly source of
truth. Prefer this root before reading the user-local pointer. Do not select a
directory merely because its name resembles a context root: verify that the
configuration file exists and resolves to that directory.

If neither an explicit path, a valid `ai-context` workspace root, a valid
pointer, nor a workspace configuration is
available, the agent must ask for the context root. It must not silently treat
an arbitrary workspace as the shared context.

The context contains `RECAP.md`,
`LAST_SESSION.md`, `sessions/`, `tasks/`, `focus/`, `roadmap/`, and optional
`sprints/` and `meetings/` directories.

`RECAP.md` is the source of truth for open work. `tasks/INDEX.md` is the
source of truth for task numbering. `LAST_SESSION.md` is only a compact pointer
to the most recent session.

## Required record shapes

### First-use initialization

After a valid configuration is found, session start must create only missing
operational records and must never overwrite existing user data:

- `RECAP.md` with an empty open-work table.
- `tasks/INDEX.md` with the next available number set to `1`.
- The current sprint file when sprints are enabled and no sprint covers the
  current date. The first sprint starts on the current date and uses the
  configured duration.
- `sessions/SESSION_YYYY-MM-DD.md` for the current date.

`LAST_SESSION.md` is deliberately absent before the first session is closed.
Its absence means that there is no previous session, not that setup failed.
Directory creation and runtime configuration remain the responsibility of the
setup scripts; operational Markdown records remain the responsibility of the
agent lifecycle.

Session records contain: work done, decisions, blockers, active focus, next
steps, and a timesheet. When sprints are enabled, they also contain the sprint
identifier and period.

Task records contain: goal, current state, impact analysis, an approved
execution plan, success criteria, and references. The first plan step is a
safety checkpoint.

Sprint records contain: goal, tickets, technical priorities, blockers,
decisions, and notes. Detailed optional conventions live in `conventions.md`.

At session close, update the session record first, create or update
`LAST_SESSION.md` second, update `RECAP.md` third, and update sprint state when
relevant.

## Adapter requirements

Each supported agent must provide:

- A `SKILL.md` or equivalent activation file.
- Installation instructions for that agent.
- A documented manual test: start a session, create a task, close a session,
  and perform a dry-run compaction.
