---
name: workflow-management
description: Manage durable work sessions, tasks, sprints, recaps, and recoverable session archives through a shared AI context directory.
---

# Workflow Management for Codex

Use this skill when the user asks to start or close a work session, manage
tasks or sprints, update a RECAP, resume project context, or compact old
session records.

Read `CORE.md` and `conventions.md` in this skill package before changing the
workflow context. Follow their shared contract exactly.

## Configuration

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`.
The user can initialize it with `setup-skills.sh`; on Windows, run the script
through WSL or Git Bash with Python 3, `zip`, and `unzip` available.

## Codex behavior

- Treat the context directory as user data: inspect before changing it.
- Ask for confirmation before compaction, deletion, external publication, or
  non-trivial execution plans.
- Prefer `compact-sessions.sh --dry-run` before a real compaction.
- Report what was verified and what remains unverified after each task.
