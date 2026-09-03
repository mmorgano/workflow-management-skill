---
name: workflow-management
description: Maintain durable, file-based work context across AI sessions, including session logs, RECAP, workflow tasks, sprints, saved notes, meeting outcomes, roadmaps, and archives. Use when the user asks to start or close a managed work session or to preserve, resume, or organize context beyond the current conversation. Do not use for ordinary coding or one-off questions with no request for durable records.
---

# Workflow Management for Codex

Use this skill only for durable workflow context: managed sessions, persistent
task records, saved or resumed notes, meeting outcomes, sprints, roadmaps,
RECAP review, or session archives. A request to start a managed work session
must activate this workflow instead of becoming a general workspace analysis.
Do not turn an ordinary coding request, one-off explanation, or transient to-do
list into workflow records.

Before changing the workflow context:

1. Read `CORE.md` for context resolution and shared invariants.
2. Read `conventions.md` before writing records.
3. Read only the references relevant to the request:
   - `references/sessions.md` for session lifecycle;
   - `references/tasks.md` for tasks and RECAP;
   - `references/planning-and-notes.md` for sprints, saved notes, meetings, or
     roadmaps;
   - `references/compaction.md` for retention and archives.

For session start or close, also read the task rules because session lifecycle
can initialize or update RECAP. Read planning rules only when sprints are
enabled or another planning record is involved.

## Configuration

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`.
Initialize it with `setup-skills.sh`; on Windows, prefer the native
`setup-skills.ps1` script. Setup refuses to replace an existing configuration
unless the user intentionally supplies `--force` or `-Force`.

Follow the context resolution order in `CORE.md`. If no valid configuration can
be resolved, ask for the context root or ask the user to run setup. Do not infer
the shared context by broadly analyzing the workspace.

## Codex behavior

- Treat the context directory as user data: inspect before changing it.
- Keep records proportional to the request and preserve unrelated content.
- Ask for confirmation before compaction, deletion, external publication, or
  execution of a non-trivial plan when approval has not already been given.
- Prefer a dry run before real compaction.
- Report what was verified and what remains unverified.
