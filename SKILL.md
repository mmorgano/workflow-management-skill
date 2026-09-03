---
name: skill-workflow-management
description: Maintain durable, file-based work context across AI sessions, including session logs, RECAP, workflow tasks, sprints, saved notes, meeting outcomes, roadmaps, and archives. Use when the user asks to start or close a managed work session or to preserve, resume, or organize context beyond the current conversation. Do not use for ordinary coding or one-off questions with no request for durable records.
---

# Workflow Management — Kiro Adapter

Use this skill only for durable workflow context: managed sessions, persistent
task records, saved or resumed notes, meeting outcomes, sprints, roadmaps,
RECAP review, or session archives. Do not turn an ordinary coding request,
one-off explanation, or transient to-do list into workflow records.

Before changing the workflow context:

1. Read `CORE.md` for context resolution and shared invariants.
2. Read `conventions.md` before writing records.
3. Read only the references relevant to the request:
   - `references/sessions.md` for session lifecycle;
   - `references/tasks.md` for tasks and RECAP;
   - `references/planning-and-notes.md` for sprints, saved notes, meetings, or
     roadmaps;
   - `references/compaction.md` for retention and archives.

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`. Use
`setup-skills.sh` to initialize or intentionally reconfigure it; on Windows,
use the native `setup-skills.ps1`.

## Kiro-specific notes

- Kiro discovers this root `SKILL.md`; shared workflow rules live in `CORE.md`,
  `conventions.md`, and `references/`.
- Verify an issue-tracker transition before making it, and ask before any
  external change that has not already been authorized.
