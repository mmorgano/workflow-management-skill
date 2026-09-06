# Usage and maintenance

[Project overview](../README.md) · [Getting started](getting-started.md)

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
| `focus/` | AI-assisted notebook for a topic: study notes, evolving analysis, project ideas, and cross-session reminders. | The user asks to preserve or resume study notes, analysis, an idea, or another topic across sessions. |
| `meetings/` | Concise records of meetings, calls, reviews, outcomes, decisions, owners, and follow-ups. | The user asks to capture or summarize a meeting or call, or a conversation produces durable outcomes. |
| `roadmap/` | Central project direction: outcomes, milestones, sequencing, and dependencies beyond one sprint. | The user asks to create, review, or update a roadmap, priorities, milestones, or future direction. |

The agent should not create a focus, meeting, or roadmap file merely because
the directory exists. Create or update one when the request or the resulting
decision needs durable context beyond the current task or session.

## Data ownership and safety

The workflow stores its state as ordinary Markdown and JSON under the context
root you choose. No external storage service is required, and the records can
be inspected, edited, backed up, or versioned with normal file tools.

Setup creates the configuration, directory structure, and context pointer. It
does not create or overwrite operational Markdown records such as `RECAP.md`
or `LAST_SESSION.md`; those are created by the session lifecycle when needed.

Compaction runs only when explicitly requested. The recommended first step is
a dry run, and real compaction verifies the ZIP archive before moving original
session files into a recoverable archive directory. Permanent deletion
requires the explicit `--delete-originals` option.

This skill complements source control and issue trackers; it does not replace
them. Its purpose is to preserve the working context that commonly falls
between commits, tickets, and individual AI conversations.

### Trigger examples

Use natural language; no command syntax or fixed template is required.

| Intent | Example requests | Expected record |
|---|---|---|
| Focus | “Keep durable notes on PostgreSQL time-series.” “Save this idea for the project.” “Resume my notes on …” | Create or update `focus/<slug>.md`; derive a clear title and filename from the topic. |
| Meeting | “Capture the notes from this call.” “Summarize the meeting and save decisions.” “Record these follow-ups.” | Create or update `meetings/MEETING_YYYY-MM-DD-<slug>.md`. |
| Roadmap | “Show the project roadmap.” “Add this milestone.” “Reprioritize the next quarter.” | Create or update an appropriate `roadmap/<slug>.md` file. |

## Requirements for compaction

- Bash
- Python 3
- `zip` and `unzip`

Windows setup is native PowerShell, but compaction is currently Bash-based and
must be run through Git Bash or WSL.

The configured retention is a minimum. Compaction always preserves at least 25
recent days and, when sprints are enabled, the current and previous sprint:

```text
effective retention = max(configured days, 25, 2 × sprint duration in days)
```

## Daily use

Ask the active agent to start or close a session, create a task, show the
RECAP, plan a sprint, or compact sessions. The agent follows `CORE.md` and its
adapter instructions. Review compaction first with:

```bash
bash ./compact-sessions.sh --dry-run
```

## Verification

Run these checks from the repository root. Run the shared smoke tests in Bash:

```bash
./tests/smoke-test.sh
```

On Windows, also run:

```powershell
.\tests\smoke-test.ps1
```

The tests cover portable and native Windows setup, package consistency,
recoverable compaction, incremental archives, and invalid configuration
handling. GitHub Actions runs the Bash suite on Linux and macOS and the
PowerShell suite on Windows. Follow [the Codex acceptance test](../tests/CODEX_ACCEPTANCE.md) for the manual
invocation test.

## Publishing a fork

Run the tests, avoid committing personal context or runtime configuration, and
review Git author metadata before publishing. The repository has no bundled
third-party code.

## What is included

- `CORE.md` — shared workflow contract and context-resolution rules
- `SKILL.md` — Claude Code adapter and skill entry point; its manual test has been run against a scratch context
- `packages/codex/workflow-management/` — canonical, self-contained Codex adapter and installation package
- `packages/codex/workflow-management/agents/openai.yaml` — Codex UI metadata and default prompt
- `references/` — session, task, planning, and compaction rules loaded on demand
- `setup-skills.sh` — creates the context configuration and directory layout
- `setup-skills.ps1` — native Windows context setup
- `compact-sessions.sh` — safely archives old sessions
- `conventions.md` — portable defaults that defer to project-specific rules
- `examples/basic-ai-context/` — minimal starter context
