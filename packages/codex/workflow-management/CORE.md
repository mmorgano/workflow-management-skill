# Workflow Management Core

This document defines the platform-independent contract for durable workflow
context. Agent adapters provide discovery, installation, and activation details.

## Shared contract

An adapter must instruct its agent to:

1. Resolve `<AI_CONTEXT_ROOT>` from an explicit user path, a workspace root
   named `ai-context` with a valid `.workflow-config.json`, the user-local
   context pointer, or a workspace `.workflow-config.json`, in that order.
2. Read `<AI_CONTEXT_ROOT>/.workflow-config.json` before acting. Use
   `record_language` for human-authored workflow records, defaulting to
   `English` when the field is absent.
3. Treat the context as user data: inspect before editing, create only missing
   first-use records, and never overwrite existing operational records.
4. Load only the workflow reference files relevant to the current request.
5. Use `RECAP.md` as the source of truth for open work and `tasks/INDEX.md` as
   the source of truth for task numbering.
6. Update only records whose durable state changed. Do not create notes,
   meetings, roadmaps, tasks, or sprints merely because their directories exist.
7. Respect explicit user instructions, repository guidance, and platform
   policy before these portable defaults.
8. Ask before destructive operations, external publication, or execution of a
   non-trivial plan when approval has not already been given.
9. Run real session compaction only after explicit confirmation, normally after
   reviewing a dry run.

## Configuration and context resolution

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`. It
controls sprint and compaction behavior and the language of human-authored
workflow records.

Setup also writes `skill-workflow-management/context-path.json` under the
platform configuration directory. On Windows this is normally
`%USERPROFILE%\.config\skill-workflow-management\context-path.json`; on POSIX
systems it is normally
`${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management/context-path.json`.

An explicit path always wins. A multi-root workspace entry named `ai-context`
is valid only when its configuration resolves back to that directory. If no
valid explicit path, workspace root, pointer, or workspace configuration can be
found, ask the user for the context root rather than selecting an arbitrary
directory.

The context layout includes `sessions/`, `tasks/`, `sprints/`, `focus/`,
`meetings/`, `roadmap/`, and the runtime configuration. Features such as
sprints and compaction may be disabled even when their directories exist.

## Load detailed rules on demand

- For starting, resuming, checkpointing, or closing sessions, read
  `references/sessions.md`.
- For task lifecycle, numbering, or RECAP updates, read `references/tasks.md`.
- For sprints, focus notes, meetings, or roadmaps, read
  `references/planning-and-notes.md`.
- For session archives or retention, read `references/compaction.md`.

A request can require more than one reference. Do not load unrelated references.
Read `conventions.md` before writing records or applying project-level workflow
defaults.

## Shared assets

- `setup-skills.sh` creates the POSIX configuration and context layout.
- `setup-skills.ps1` provides native Windows setup.
- `compact-sessions.sh` performs recoverable session archival.
- `examples/basic-ai-context/` illustrates an empty starter context.

## Adapter requirements

Each supported agent must provide:

- a `SKILL.md` or equivalent activation file;
- installation instructions for that agent;
- a documented manual test covering session start, task creation, session
  close, and dry-run compaction.
