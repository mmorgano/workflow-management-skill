---
name: workflow-management
description: Start, resume, or close structured work sessions and maintain durable session logs, RECAP, tasks, sprints, focus topics, meeting outcomes, and roadmaps. Use whenever the user asks to start, begin, resume, or close a work session; manage workflow tasks or sprints; track a complex topic; capture meeting decisions; review project direction; or compact session records.
---

# Workflow Management for Codex

Use this skill whenever the user asks to start, begin, resume, or close a work
session; review the current work state; manage workflow tasks or sprints;
update a RECAP; track a multi-session focus topic; record meeting outcomes;
plan or revise a roadmap; or compact old session records. A request to start a work
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
2. In a multi-root workspace, use the root named `ai-context` when it contains
   `.workflow-config.json`; verify the configuration before using it.
3. Read `skill-workflow-management/context-path.json` from the user-local
   configuration directory. On Windows, check
   `%USERPROFILE%\.config\skill-workflow-management\context-path.json`. On
   POSIX systems, check
   `${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management/context-path.json`.
4. Use `.workflow-config.json` in the current workspace when present.
5. If none of these resolve to a valid configured directory, ask the user for
   the context root or ask them to run setup. Do not infer the shared context
   by broadly analyzing the workspace.

## Codex behavior

- Treat the context directory as user data: inspect before changing it.
- Follow the session lifecycle and record rules in `CORE.md` and
  `conventions.md`; do not duplicate or replace them in this adapter.
- Ask for confirmation before compaction, deletion, external publication, or
  non-trivial execution plans.
- Prefer `compact-sessions.sh --dry-run` before a real compaction.
- Report what was verified and what remains unverified after each task.
