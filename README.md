# workflow-management-skill

A portable workflow-management core for AI coding agents: daily sessions,
tasks, optional sprints, durable project context, and recoverable archives.

## What is included

- `CORE.md` — shared workflow contract and data model
- `SKILL.md` — Kiro adapter, retained for existing installations
- `adapters/claude-code/` — Claude Code adapter; its manual test has been run against a scratch context
- `packages/codex/workflow-management/` — canonical, self-contained Codex adapter and installation package
- `setup-skills.sh` — creates the context configuration and directory layout
- `setup-skills.ps1` — native Windows context setup
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

One `ai-context` can serve several projects: add the same context root to each
project workspace when you want shared tasks, notes, meetings, and direction.
Use a separate `ai-context` root for a project when its history or information
must stay independent. A workspace should include only the context intended
for that project session, so the agent never has to guess which records to
update.

## `ai-context` layout

`ai-context` is shared durable work context, not project source code. Keep it
as one workspace root and use each area for a distinct kind of information:

| Path | Purpose | Update when |
|---|---|---|
| `.workflow-config.json` | Runtime options and the context root. | Setup or configuration changes. |
| `RECAP.md` | Compiled view of open work across projects. | Open work, blockers, or priorities change. |
| `LAST_SESSION.md` | Short pointer to the last closed session. | A work session is closed. |
| `sessions/` | Daily work log: work done, decisions, blockers, and next steps. | A session starts, reaches a checkpoint, or closes. |
| `tasks/` | Numbered, execution-ready work items. `INDEX.md` owns numbering; `todo/` and `done/` reflect lifecycle. | Creating, progressing, or completing a task. |
| `sprints/` | Time-boxed goals, tickets, decisions, and blockers. | Planning or updating the active sprint. |
| `focus/` | AI-assisted notebook for a topic: study notes, evolving analysis, project ideas, and cross-session reminders. | The user asks to take notes, study, explore, save an idea, or resume a topic. |
| `meetings/` | Concise records of meetings, calls, reviews, outcomes, decisions, owners, and follow-ups. | The user asks to capture or summarize a meeting or call, or a conversation produces durable outcomes. |
| `roadmap/` | Central project direction: outcomes, milestones, sequencing, and dependencies beyond one sprint. | The user asks to create, review, or update a roadmap, priorities, milestones, or future direction. |

The agent should not create a focus, meeting, or roadmap file merely because
the directory exists. Create or update one when the request or the resulting
decision needs durable context beyond the current task or session.

### Trigger examples

Use natural language; no command syntax or fixed template is required.

| Intent | Example requests | Expected record |
|---|---|---|
| Focus | “Take notes on PostgreSQL time-series.” “Let’s study this topic.” “Save this idea for the project.” “Resume my notes on …” | Create or update `focus/<slug>.md`; derive a clear title and filename from the topic. |
| Meeting | “Capture the notes from this call.” “Summarize the meeting and save decisions.” “Record these follow-ups.” | Create or update `meetings/MEETING_YYYY-MM-DD-<slug>.md`. |
| Roadmap | “Show the project roadmap.” “Add this milestone.” “Reprioritize the next quarter.” | Create or update an appropriate `roadmap/<slug>.md` file. |

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
