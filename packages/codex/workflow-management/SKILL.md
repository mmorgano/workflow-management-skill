---
name: workflow-management
description: Maintain durable, file-based work context across AI sessions, including session logs, RECAP, workflow tasks, sprints, saved notes, meeting outcomes, roadmaps, and archives. Use when the user asks to start or close a managed work session, to preserve, resume, or organize context beyond the current conversation, or to start a new project, repository, or component from scratch. Do not use for ordinary coding or one-off questions with no request for durable records.
---

# Workflow Management for Codex

Use this skill only for durable workflow context: managed sessions, persistent
task records, saved or resumed notes, meeting outcomes, sprints, roadmaps,
steering documents, decision records, long-running project tracking (status
reports, a Risk & Issue register, phase-gates), RECAP review, session
archives, or bootstrapping a new repository or component. A request to start
a managed work session must activate this workflow instead of becoming a
general workspace analysis. Do not turn an ordinary coding request, one-off
explanation, or transient to-do list into workflow records.

Before changing the workflow context:

1. Read `CORE.md` for context resolution and shared invariants.
2. Read `conventions.md` before writing records.
3. Read only the references relevant to the request:
   - `references/sessions.md` for session lifecycle;
   - `references/tasks.md` for tasks and RECAP;
   - `references/recap-maintenance.md` for oversized RECAP or task-index
     maintenance;
   - `references/planning-and-notes.md` for sprints, saved notes, meetings, or
     roadmaps;
   - `references/steering.md` for project intake, steering documents, decision
     records, session rituals, or documentation hygiene;
   - `references/tracking.md` for activating the `long-vision` tracking tier,
     status reports, a Risk & Issue register, phase-gates, or the extended
     closure checks;
   - `references/bootstrap.md` for starting a new repository, component,
     package, or service from scratch;
   - `references/setup-guided.md` for agent-guided context initialization;
   - `references/onboarding.md` for the first-run introduction when no context
     resolves, or for plain-language answers about folders, what else the skill
     can do, or tasks versus a long project;
   - `references/compaction.md` for retention and archives.

For session start or close, also read the task rules because session lifecycle
can initialize or update RECAP. Read planning rules only when sprints are
enabled or another planning record is involved.

## Configuration

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`.
Prefer agent-guided setup: when the user asks to initialize a workflow context,
read `references/setup-guided.md` and create the configuration and directory
layout directly with the available file tools, asking before overwriting
anything. `setup-skills.sh` and `setup-skills.ps1` remain available as
automation fallbacks for technical users and tests. Setup refuses to replace an
existing configuration unless the user intentionally supplies `--force`,
`-Force`, or explicitly authorizes the equivalent overwrite during
agent-guided setup.

Follow the context resolution order in `CORE.md`. Do not infer the shared
context by broadly analyzing the workspace, and never attach a context that
belongs to a different workspace. If the order resolves nothing, follow
`references/sessions.md` § "When no context resolves": offer to create a
context for this workspace; only if the user declines, ask for an existing
path or proceed without workflow records.

## Codex behavior

- Treat the context directory as user data: inspect before changing it.
- Keep records proportional to the request and preserve unrelated content.
- Ask for confirmation before compaction, deletion, external publication, or
  execution of a non-trivial plan when approval has not already been given.
- Prefer a dry run before real compaction.
- Report what was verified and what remains unverified.
