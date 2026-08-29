# workflow-management-skill

A portable workflow-management core for AI coding agents: daily sessions,
tasks, optional sprints, durable project context, and recoverable archives.

## What is included

- `CORE.md` — shared workflow contract and data model
- `SKILL.md` — Kiro adapter, retained for existing installations
- `adapters/codex/` — Codex adapter source
- `adapters/claude-code/` — Claude Code adapter; its manual test has been run against a scratch context
- `packages/codex/workflow-management/` — self-contained Codex installation package
- `setup-skills.sh` — creates the context configuration and directory layout
- `setup-skills.ps1` — native Windows context setup
- `setup-skills.bat` — optional Git Bash compatibility launcher for Windows
- `compact-sessions.sh` — safely archives old sessions
- `conventions.md` — optional detailed team conventions
- `examples/basic-ai-context/` — minimal starter context

## Agent support

| Agent | Status |
|---|---|
| Kiro | Supported via root `SKILL.md`; pending in-app validation |
| Codex | Supported via the self-contained package; Windows manual test documented |
| Claude Code | Supported via `adapters/claude-code/SKILL.md`; manual test steps run against a scratch context |
| Other agents | Implement the contract in `CORE.md` |

## Install for Codex

Install only the self-contained Codex package. Do not install the repository
root because it contains adapters for multiple agents and would expose
duplicate skill names.

In Codex, invoke `$skill-installer` with:

```text
Install the skill from https://github.com/mmorgano/workflow-management-skill/tree/main/packages/codex/workflow-management
```

The installed folder contains exactly one `SKILL.md`. Codex can invoke it
explicitly as `$workflow-management` or implicitly when the request matches its
description. Restart Codex if a newly installed version does not appear.

## Configure the context

Setup creates the configuration, directory layout, and user-local context
pointer. Operational Markdown records are intentionally created by the agent
when the first session starts, not by setup.

### Windows

From PowerShell in the cloned repository or installed package:

```powershell
.\setup-skills.ps1 -ContextRoot C:\projects\ai-context
```

This native setup has no Python or Bash dependency.

If you specifically need to use the Bash setup from Command Prompt,
PowerShell, or File Explorer, use the optional compatibility launcher:

```bat
setup-skills.bat --path C:\projects\ai-context
```

It requires Git for Windows and a `python3` executable available from Git
Bash. Prefer `setup-skills.ps1` for new Windows installations.

### Linux, macOS, Git Bash, or WSL

Run the interactive wizard:

```bash
./setup-skills.sh
```

For non-interactive setup:

```bash
./setup-skills.sh --path /absolute/path/to/ai-context
```

The Bash setup requires Python 3. Session compaction additionally requires
`zip` and `unzip`.

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

## Start the first session

Open any workspace and ask:

```text
Let's start a new work session.
```

The agent resolves the configured shared context, initializes missing first-use
records without overwriting user data, creates today's session file, and shows
the current work state. `LAST_SESSION.md` is created only when the first
session is closed.

## Requirements for compaction

- Bash
- Python 3
- `zip` and `unzip`

## Daily use

Ask the active agent to start or close a session, create a task, show the
RECAP, plan a sprint, or compact sessions. The agent follows `CORE.md` and its
adapter instructions. Review compaction first with:

```bash
./compact-sessions.sh --dry-run
```

## Verification

Run the shared smoke tests in Bash:

```bash
./tests/smoke-test.sh
```

On Windows, also run:

```powershell
.\tests\smoke-test.ps1
```

The tests cover portable and native Windows setup, package consistency,
recoverable compaction, incremental archives, and invalid configuration
handling. Follow `tests/CODEX_ACCEPTANCE.md` for the manual invocation test.

## Publishing a fork

Run the tests, avoid committing personal context or runtime configuration, and
review Git author metadata before publishing. The repository has no bundled
third-party code.

## License

[MIT](LICENSE) © 2026 Maurizio Morgano.
