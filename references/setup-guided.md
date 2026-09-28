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
    "keep_recent_days": null,
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

### Platform path construction (agents)

`CORE.md` documents the pointer location using `%USERPROFILE%` (CMD syntax) and
`$HOME` / `$XDG_CONFIG_HOME` (POSIX syntax). These are documentation
conventions, not executable expressions. When constructing the path through
file-write tools rather than a shell script, build it safely:

- **Windows**: read `$env:USERPROFILE` (PowerShell) or the `USERPROFILE`
  environment variable, then join path segments with the OS separator.
  Never concatenate the home directory string and `.config` or `.kiro` by hand —
  this is the direct cause of paths like `C:\Users\<name>.kiro` instead of
  `C:\Users\<name>\.kiro`.
  Correct approach (equivalent to what `setup-skills.ps1` does, and compatible
  with Windows PowerShell 5.1, where `Join-Path` only takes a single
  `-ChildPath`):
    $base = $env:USERPROFILE  # e.g. C:\Users\<name>
    $pointer = Join-Path $base ".config\skill-workflow-management\context-path.json"
  If `USERPROFILE` is empty or unresolvable, stop and report the error instead
  of proceeding with an incomplete path.

- **POSIX**: prefer `$XDG_CONFIG_HOME` when set; otherwise use `$HOME/.config`.
  Use path-join semantics, not string concatenation.

- **Reuse the verified value, do not retype it.** Whichever way the path was
  computed and checked (`Join-Path`, `Test-Path`, an `os.path.join` equivalent,
  or simply printing it), pass that exact same string, character for character,
  as the destination argument to the file-write tool. Regenerating or
  paraphrasing the path for the write call, even from the same recipe, is how
  the separator gets dropped again after the check already passed: the
  computed value was correct, but the call that actually wrote the file
  reconstructed the string from scratch and repeated the original bug. Copy
  the verified string; never re-derive it a second time.

These rules apply specifically to agent-guided setup where the agent invokes
file tools directly. The setup scripts (`setup-skills.ps1`, `setup-skills.sh`)
already handle this correctly and do not need changes.

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
- a short map of the folders, one line each, saying that `sessions/` and
  `tasks/` are used from the first day and the others stay empty until needed,
  and inviting the user to ask what any folder is for or what else the skill
  can do (see `references/onboarding.md`, "Later questions");
- anything not verified.

