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

Setup refuses to replace an existing configuration or a pointer to a different
context. Use `-Force` on PowerShell or `--force` on Bash only when you intend to
reconfigure the context.

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

## Start the first session

Open any workspace and ask:

```text
Let's start a new work session.
```

The agent resolves the configured shared context, initializes missing first-use
records without overwriting user data, creates today's session file, and shows
the current work state. `LAST_SESSION.md` is created only when the first
session is closed.
