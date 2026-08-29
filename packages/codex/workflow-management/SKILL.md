---
name: workflow-management
description: Start, resume, or close structured work sessions and maintain durable session logs, RECAP, tasks, focus topics, and optional sprints. Use whenever the user asks to start, begin, resume, or close a work session, review current work, manage workflow tasks or sprints, or compact session records.
---

# Workflow Management for Codex

Use this skill whenever the user asks to start, begin, resume, or close a work
session; review the current work state; manage workflow tasks or sprints;
update a RECAP; or compact old session records. A request to start a work
session must activate this workflow instead of becoming a general workspace
analysis request.

Read `CORE.md` and `conventions.md` in this skill package before changing the
workflow context. Follow their shared contract exactly.

## Configuration

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`.
Initialize it with `setup-skills.sh`; on Windows, prefer the native
`setup-skills.ps1` script.

Resolve `AI_CONTEXT_ROOT` in this order:

1. Use a path explicitly provided by the user.
2. Read `skill-workflow-management/context-path.json` from the user-local
   configuration directory. On Windows, check
   `%USERPROFILE%\.config\skill-workflow-management\context-path.json`. On
   POSIX systems, check
   `${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management/context-path.json`.
3. Use `.workflow-config.json` in the current workspace when present.
4. If none of these resolve to a valid configured directory, ask the user for
   the context root or ask them to run setup. Do not infer the shared context
   by broadly analyzing the workspace.

## Session lifecycle

At session start:

1. Verify the current date with a system command.
2. Read the configuration.
3. Treat missing `RECAP.md`, `tasks/INDEX.md`, current sprint, and today's
   session file as normal first-use state and create them according to
   `CORE.md` and `conventions.md`. Never overwrite existing records.
4. Treat a missing `LAST_SESSION.md` as “no previous session”; do not create it
   yet.
5. Read the initialized records and report the current sprint, open tasks,
   blockers, and next steps.

At session close:

1. Finalize the session file.
2. Create or update `LAST_SESSION.md`.
3. Update `RECAP.md`.
4. Update the sprint when relevant.

## Codex behavior

- Treat the context directory as user data: inspect before changing it.
- Create missing first-use records only after resolving a valid configured
  context.
- Ask for confirmation before compaction, deletion, external publication, or
  non-trivial execution plans.
- Prefer `compact-sessions.sh --dry-run` before a real compaction.
- Report what was verified and what remains unverified after each task.
