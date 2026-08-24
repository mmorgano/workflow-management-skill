# Workflow Management Core

This document defines the platform-independent behavior of the workflow-management skill.
Agent adapters supply only installation details and agent-specific activation language.

## Shared contract

An adapter must instruct its agent to:

1. Read `<AI_CONTEXT_ROOT>/.workflow-config.json` before assuming that sprints or compaction are enabled.
2. At session start, read `RECAP.md`, `LAST_SESSION.md`, and the current sprint file when enabled.
3. Use `tasks/INDEX.md` as the source of truth for task numbers.
4. Update session, RECAP, and sprint records as work changes.
5. Ask before destructive operations, external publication, or non-trivial execution plans.
6. Offer session compaction; never run it without user confirmation.

## Shared assets

- `setup-skills.sh` creates the configuration and context directory structure.
- `compact-sessions.sh` performs recoverable session archival.
- `conventions.md` contains the detailed workflow conventions.
- `examples/basic-ai-context/` provides a minimal starting context.

## Configuration and layout

The runtime file is `<AI_CONTEXT_ROOT>/.workflow-config.json`. It controls
whether sprints and compaction are active. The context contains `RECAP.md`,
`LAST_SESSION.md`, `sessions/`, `tasks/`, `focus/`, `roadmap/`, and optional
`sprints/` and `meetings/` directories.

`RECAP.md` is the source of truth for open work. `tasks/INDEX.md` is the
source of truth for task numbering. `LAST_SESSION.md` is only a compact pointer
to the most recent session.

## Required record shapes

Session records contain: work done, decisions, blockers, active focus, next
steps, and a timesheet. When sprints are enabled, they also contain the sprint
identifier and period.

Task records contain: goal, current state, impact analysis, an approved
execution plan, success criteria, and references. The first plan step is a
safety checkpoint.

Sprint records contain: goal, tickets, technical priorities, blockers,
decisions, and notes. Detailed optional conventions live in `conventions.md`.

## Adapter requirements

Each supported agent must provide:

- A `SKILL.md` or equivalent activation file.
- Installation instructions for that agent.
- A documented manual test: start a session, create a task, close a session,
  and perform a dry-run compaction.
