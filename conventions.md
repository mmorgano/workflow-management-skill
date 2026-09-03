# Workflow Management Conventions

These are portable defaults for workflow records. Explicit user instructions,
repository guidance, and platform policy take precedence. Do not impose a
particular programming language, linter, branch model, merge strategy, or
deployment process when the project has its own conventions.

## Record language

Sessions, RECAP entries, tasks, focus notes, meetings, and roadmaps use
`record_language` from `.workflow-config.json`, defaulting to `English` when the
field is absent. Code, project documentation, commits, and external tracker
content follow the conventions of the project they belong to.

## Record-writing defaults

- Keep the useful current state near the top.
- Preserve dated history below it when a timeline materially helps.
- Link related records instead of duplicating their full contents.
- Record durable outcomes and unresolved follow-ups, not raw chat transcripts.
- Create or update only the records relevant to the user's request or to a
  durable change produced by the work.

## Safety and verification

- Inspect a record before changing it and preserve unrelated user content.
- Use a safety checkpoint only when the planned work has meaningful rollback
  risk. Choose a checkpoint appropriate to the project; do not create a tag or
  backup automatically for every task.
- Require plan approval only when the plan is non-trivial, destructive,
  externally mutating, or otherwise needs a user decision.
- Run checks appropriate to the project and the change. Do not require a
  specific linter, score, test suite, or tool unless the project requires it.
- Report what was verified and what remains unverified.
- Follow the project's Git and release conventions. Create commits, branches,
  tags, pushes, pull requests, or deployments only when requested or already
  authorized by the active workflow.

## Detailed workflows

- Session lifecycle: `references/sessions.md`
- Tasks and RECAP: `references/tasks.md`
- Sprints, focus notes, meetings, and roadmaps:
  `references/planning-and-notes.md`
- Session retention and archives: `references/compaction.md`
