# Getting started

[Project overview](../README.md) · [Usage and maintenance](usage-and-maintenance.md)

## Choose your assistant

[Codex](#install-for-codex) or [Claude Code](../SKILL.md#install). See the [current support status](../README.md#portable-across-supported-assistants).

## Install for Codex

Install only the self-contained Codex package. Do not install the repository
root: it is the Claude Code skill and would expose a duplicate skill name.

In Codex, invoke `$skill-installer` with:

```text
Install the skill from https://github.com/mmorgano/workflow-management-skill/tree/main/packages/codex/workflow-management
```

The installed folder contains exactly one `SKILL.md`. Codex can invoke it
explicitly as `$workflow-management` or implicitly when the request matches its
description. Restart Codex if a newly installed version does not appear.

This repository currently distributes a standalone skill package for direct
installation. Packaging it as a plugin is a separate future distribution step
for publishing through the shared plugin directory; it is not required by the
runtime workflow.

## Configure the context

Setup creates the configuration, directory layout, and user-local context
pointer. Operational Markdown records are intentionally created by the agent
when the first session starts, not by setup.

The recommended path is **agent-guided setup**: ask the assistant to initialize
a workflow context, choose the context root, and let it create the same files
and directories that the scripts would create. This keeps the install flow the
same on Windows, Linux, macOS, WSL, and locked-down company machines where shell
scripts may be inconvenient.

Use the setup scripts when you want deterministic automation, CI coverage, or a
technical fallback. Both the agent-guided path and scripts must refuse to
replace an existing configuration or a pointer to a different context unless
you explicitly approve reconfiguration.

### Agent-guided setup

Open the project workspace and ask:

```text
Initialize workflow management for this workspace.
```

The assistant should:

1. choose or confirm `<AI_CONTEXT_ROOT>`;
2. create `.workflow-config.json`;
3. create the standard directories;
4. create a user-local pointer only when appropriate;
5. leave operational records such as `RECAP.md` and `LAST_SESSION.md` for the
   first session lifecycle;
6. report what it created and what remains unverified.

If a context already exists, the assistant should inspect it and reuse it. It
should ask before changing an existing config or replacing a pointer.

### Script fallback

The scripts remain available for repeatable setup and tests.

### Windows

From PowerShell in the cloned repository or installed package:

```powershell
.\setup-skills.ps1 -ContextRoot C:\projects\ai-context
```

This native setup has no Python or Bash dependency.

Set the language of sessions, tasks, focus notes, meetings, roadmaps, and
RECAP entries with `-RecordLanguage` (default: `English`):

```powershell
.\setup-skills.ps1 -ContextRoot C:\projects\ai-context -RecordLanguage English
```

To intentionally replace an existing configuration:

```powershell
.\setup-skills.ps1 -ContextRoot C:\projects\ai-context -Force
```

### Linux, macOS, Git Bash, or WSL

Run the interactive wizard:

```bash
bash ./setup-skills.sh
```

For non-interactive setup:

```bash
bash ./setup-skills.sh --path /absolute/path/to/ai-context
```

To set the record language in non-interactive Bash setup:

```bash
bash ./setup-skills.sh --path /absolute/path/to/ai-context --record-language English
```

To intentionally replace an existing configuration:

```bash
bash ./setup-skills.sh --path /absolute/path/to/ai-context --force
```

The Bash setup requires Python 3. Session compaction additionally requires
`zip` and `unzip`.

Existing contexts without `record_language` retain the backward-compatible
default of English. README files, code, and commit messages remain English.

New session files include a language-neutral internal marker used by
compaction; visible headings and content still use the configured language.
Existing Italian and English sessions remain compatible.

### Recommended: add `ai-context` to the workspace

Keep `ai-context` as a separate root in each multi-root workspace alongside
the project you are working on. For example, the workspace can contain:

```text
my-project/             # project source
ai-context/             # shared sessions, tasks, RECAP, and sprints
```

In VS Code, use **File > Add Folder to Workspace...**, select the configured
`ai-context` directory (for example `C:\projects\ai-context`), then save the
workspace file. Start Codex from that multi-root workspace.

When a root named `ai-context` contains `.workflow-config.json`, the Codex
adapter uses it before the user-local context pointer. This keeps the records
visible in Explorer and avoids relying on access to a file under the user
profile, which can be restricted by a workspace sandbox.

One `ai-context` can serve several projects: add the same context root to each
project workspace when you want shared tasks, notes, meetings, and direction.
Use a separate `ai-context` root for a project when its history or information
must stay independent. A workspace should include only the context intended
for that project session, so the agent never has to guess which records to
update.

<a id="per-project-contexts-multi-workspace"></a>

### Per-project contexts (multi-workspace)

To keep an independent context per project on one machine, give each its own
directory and attach it through that project's multi-root workspace:

```text
C:\projects\
  ai_context_alpha\        # .workflow-config.json (its own context)
  ai_context_beta\         # .workflow-config.json
  alpha\   beta\           # project source
  alpha.code-workspace     # folders: [ "alpha", "ai_context_alpha" ]
  beta.code-workspace      # folders: [ "beta", "ai_context_beta" ]
```

The directory name is free; the agent resolves the context from whichever
workspace root contains `.workflow-config.json`. A workspace-local context
always takes precedence over the machine-wide pointer, so the two projects
never collide.

Scaffold one with `--here` (PowerShell `-Here`), which creates the directory
and configuration but does **not** touch the user-local pointer:

```powershell
.\setup-skills.ps1 -ContextRoot C:\projects\ai_context_alpha -Here
```

```bash
bash ./setup-skills.sh --path /abs/path/to/ai_context_alpha --here
```

Setup then prints the `folders` snippet to add to the `.code-workspace` file.
Add it with **File > Add Folder to Workspace...** and reload the window.

If you start a session in a workspace that has no context, the agent offers to
create one this way — it proposes a directory name, and creates it only after
you confirm.

## Optional: a SessionStart hook for more reliable activation (Claude Code)

Skill activation is a judgment call the model makes by matching your request
against this skill's description — even a request that closely echoes the
trigger phrasing ("Let's start a new work session") can occasionally be
answered directly instead of invoking the skill, especially in a brand-new,
empty project where there is nothing yet to signal "this needs a managed
session."

Claude Code's `SessionStart` hook runs deterministically at the start of every
session, independent of what you type first, and its output is added to the
model's context. Adding one is optional and does not replace the skill or
guarantee activation — it only raises the odds the skill gets considered
before other work starts.

Add this to `~/.claude/settings.json` (global, so it also covers brand-new
project folders) or to a project's `.claude/settings.json` (team-shared):

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: if this is the start of a new work session, or a new project starting from an empty folder, consider invoking the workflow-management skill before doing anything else.'"
          }
        ]
      }
    ]
  }
}
```

Merge it into the existing file rather than replacing it if `hooks` or other
keys are already present. Review, edit, or remove it later from Claude Code's
`/hooks` menu. This is Claude-Code-specific; other supported assistants do not
read this file.

## Start the first session

Open any workspace and ask:

```text
Let's start a new work session.
```

The agent resolves the configured shared context, initializes missing first-use
records without overwriting user data, creates today's session file, and shows
the current work state. `LAST_SESSION.md` is created only when the first
session is closed.
