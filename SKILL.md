---
name: skill-workflow-management
description: Structured sessions, tasks, optional sprints, recap tracking, and recoverable session archives.
---

# Workflow Management — Kiro Adapter

Use this skill for session start/end, task or sprint work, project-status
updates, workflow setup, and session compaction.

Read `CORE.md` before acting. Read `conventions.md` only when its detailed
team conventions are relevant. The runtime configuration is
`<AI_CONTEXT_ROOT>/.workflow-config.json`; use `setup-skills.sh` to create it.

## Start a session

1. Verify the current date.
2. Read the configuration, `RECAP.md`, `LAST_SESSION.md`, and the current
   sprint file when enabled.
3. Open or create `sessions/SESSION_YYYY-MM-DD.md`.
4. Summarize open tasks, blockers, next steps, and active sprint information.
5. If compaction is enabled, offer a dry-run for eligible sessions; do not run
   compaction without the user's confirmation.

## During and after work

- Record work, decisions, blockers, and next steps in the session.
- Update RECAP and sprint status as soon as they change.
- Before ending, update the session first, then `LAST_SESSION.md`, then RECAP.
- Use `tasks/INDEX.md` before assigning a task number. Never reuse a number.
- Request explicit approval before a non-trivial execution plan, destructive
  operation, external publication, or issue-tracker transition.

## Compaction

Use `compact-sessions.sh --dry-run` first. The script retains a safety window,
verifies archives before originals are touched, and moves originals to a
recoverable archive location by default. Use `--delete-originals` only with
explicit confirmation.

## Data rules

- `RECAP.md` is the source of truth for open work.
- `LAST_SESSION.md` is a minimal pointer, not a diary.
- Session files are daily records; task files are plans; focus files hold
  multi-session analysis.
- Keep current state at the top of a document and append history below it.

## Language and integrations

Default documentation and templates are English; teams may choose the language
of session content. When an issue tracker is used, verify transitions and ask
before changing an external ticket.
