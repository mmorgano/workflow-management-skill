# Workflow Management Core

This document defines the platform-independent contract for durable workflow
context. Agent adapters provide discovery, installation, and activation details.

## Shared contract

An adapter must instruct its agent to:

1. Resolve `<AI_CONTEXT_ROOT>` in the order defined under "Configuration and
   context resolution": an explicit user path, a workspace-local context, the
   user-local pointer, then a prompt. A workspace-local context always precedes
   the user-local pointer.
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

Unless `--here` / `-Here` is used, setup also writes
`skill-workflow-management/context-path.json` under the platform configuration
directory. On Windows this is normally
`%USERPROFILE%\.config\skill-workflow-management\context-path.json`; on POSIX
systems it is normally
`${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management/context-path.json`.

### Resolution order

Resolve `<AI_CONTEXT_ROOT>` to the first of these that succeeds:

1. **An explicit path** supplied by the user for this request.
2. **A workspace-local context**: a root of the current multi-root workspace
   that contains a `.workflow-config.json` whose `ai_context_root` resolves
   back to that same directory. The directory name is not significant;
   `ai-context` is only the documented convention for the single-context case.
   If more than one workspace root qualifies, ask which one to use.
3. **A `.workflow-config.json` in the current working directory or workspace
   folder** that resolves back to itself.
4. **The user-local pointer** `context-path.json`:
   - map form — `{ "contexts": { "<workspace path>": "<context path>", … },
     "default": "<context path>" }`: use the entry whose key matches the
     current workspace, else `default`, else ask;
   - string form (legacy) — `{ "ai_context_root": "<context path>" }`.
5. **Otherwise**, do not select an arbitrary directory. Offer to create a
   context for this workspace (see `references/sessions.md`) or ask for the
   path.

Steps 2 and 3 (workspace-local) always precede step 4 (the machine-wide
pointer), so independent projects on one machine each resolve to their own
context. A context scaffolded with `--here` is attached through step 2.

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
- Either script with `--here` / `-Here` scaffolds a per-project context that is
  attached through a multi-root workspace root, without reading or writing the
  user-local pointer.
- `compact-sessions.sh` performs recoverable session archival.
- `examples/basic-ai-context/` illustrates an empty starter context.

## Adapter requirements

Each supported agent must provide:

- a `SKILL.md` or equivalent activation file;
- installation instructions for that agent;
- a documented manual test covering session start, task creation, session
  close, and dry-run compaction.
