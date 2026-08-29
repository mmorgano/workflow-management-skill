---
name: skill-workflow-management
description: Structured sessions, tasks, sprints, focus notes, meeting notes, roadmaps, recap tracking, and recoverable session archives.
---

# Workflow Management — Kiro Adapter

Use this skill for workflow requests: starting or closing a session, managing
tasks or sprints, taking or resuming notes, studying a topic, saving an idea,
capturing a meeting or call, planning a roadmap, reviewing project status, or
compacting session records.

Read `CORE.md` before acting. Read `conventions.md` when its record formats or
detailed conventions are relevant. The runtime configuration is
`<AI_CONTEXT_ROOT>/.workflow-config.json`; use `setup-skills.sh` to initialize
it.

## Kiro-specific notes

- Kiro discovers this root `SKILL.md`; the shared operational rules live in
  `CORE.md` and `conventions.md` rather than in this adapter.
- Verify an issue-tracker transition before making it, and ask before any
  external change.
