# Agent-Guided Setup

Read this reference when the user asks to initialize, configure, or attach a
workflow context without running setup scripts.

The goal is to make setup portable across Windows, Linux, macOS, WSL, locked
company machines, and assistants that have file tools but should not require
shell scripts for ordinary use.

## Principle

Agent-guided setup performs the same logical steps as `setup-skills.sh` and
`setup-skills.ps1`, but through inspected file operations and explicit user
confirmation.

Scripts remain supported as automation fallbacks for repeatable tests,
technical users, and CI. Do not remove or ignore them.

## Inputs to Confirm

Before writing files, confirm:

- the intended `<AI_CONTEXT_ROOT>`;
- whether setup is workspace-local only (equivalent to `--here` / `-Here`,
  recommended: the context is attached through the workspace root and the
  machine-wide pointer is left untouched) or should also write the user-local
  context pointer;
- `record_language`, defaulting to `English`;
- sprint settings, if requested;
- compaction settings, if requested;
- whether an existing config should be reused or intentionally replaced.

Do not infer a context from an unrelated workspace.

## Files and Directories

Create the context root if it does not exist, then create:

```text
sessions/
tasks/
tasks/todo/
tasks/done/
sprints/
focus/
meetings/
roadmap/
```

Create `.workflow-config.json` when missing:

```json
{
  "version": "1.2.0",
  "ai_context_root": "<absolute context root>",
  "sprint": {
    "enabled": false,
    "duration_weeks": 2
  },
  "compaction": {
    "enabled": true,
    "retention_days": 30,
    "group_by": "month"
  },
  "record_language": "English"
}
```

If the user asks for RECAP maintenance defaults, add:

```json
{
  "recap_maintenance": {
    "enabled": true,
    "soft_limit_kb": 40,
    "hard_limit_kb": 60,
    "critical_limit_kb": 100,
    "keep_recent_completed": 10,
    "archive_closed_sections": true
  }
}
```

Merge JSON sections into one object; do not create duplicate top-level objects.

## Operational Records

Do not create `RECAP.md`, `LAST_SESSION.md`, session files, or task files during
setup just because the directories exist. Those records are created by the
session and task lifecycle when needed.

If the user explicitly wants starter records, keep them minimal and explain
that they are operational state, not required setup files.

## User-Local Pointer

For machine-wide configuration, write `context-path.json` under the platform
configuration directory described in `CORE.md`. Prefer the map form:

```json
{
  "contexts": {
    "<workspace path>": "<absolute context root>"
  },
  "default": "<absolute context root>"
}
```

For workspace-local setup, do not write or modify the user-local pointer unless
the user explicitly asks.

Never overwrite an existing pointer to a different context without explicit
confirmation.

## Existing Contexts

If `.workflow-config.json` already exists:

- read it;
- verify `ai_context_root` resolves to the context directory;
- create only missing standard directories;
- preserve existing options unless the user requests a change.

If the config points somewhere else, stop and ask before changing anything.

## Completion Report

Report:

- context root used;
- config created or reused;
- pointer created, reused, skipped, or left unchanged;
- directories created or already present;
- operational records intentionally not created;
- anything not verified.

