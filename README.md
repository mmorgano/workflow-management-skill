# workflow-management-skill

A portable workflow-management core for AI coding agents: daily sessions,
tasks, optional sprints, durable project context, and recoverable archives.

## What is included

- `CORE.md` — shared workflow contract and data model
- `SKILL.md` — Kiro adapter, retained for existing installations
- `adapters/codex/` — initial Codex adapter, pending in-app validation
- `adapters/claude-code/` — Claude Code adapter; its manual test has been run against a scratch context
- `setup-skills.sh` — creates the context configuration and directory layout
- `compact-sessions.sh` — safely archives old sessions
- `conventions.md` — optional detailed team conventions
- `examples/basic-ai-context/` — minimal starter context

## Agent support

| Agent | Status |
|---|---|
| Kiro | Supported via root `SKILL.md`; pending in-app validation |
| Codex | Initial adapter; pending in-app validation |
| Claude Code | Supported via `adapters/claude-code/SKILL.md`; manual test steps run against a scratch context |
| Other agents | Implement the contract in `CORE.md` |

## Requirements

- Bash
- Python 3
- `zip` and `unzip`
- WSL, Git Bash, or another Unix-compatible environment on Windows

## Quick start

Install the package in the selected agent's skills location, then run:

```bash
./setup-skills.sh
```

The wizard creates `<AI_CONTEXT_ROOT>/.workflow-config.json` and the required
directories. For non-interactive setup:

```bash
./setup-skills.sh --path /absolute/path/to/ai-context
```

Start from `examples/basic-ai-context/` if you want initial `RECAP.md`,
`LAST_SESSION.md`, and task-index files.

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

The tests cover configuration, recoverable compaction, incremental archives,
and invalid configuration handling.

## Publishing a fork

Run the tests, avoid committing personal context or runtime configuration, and
review Git author metadata before publishing. The repository has no bundled
third-party code.

## License

[MIT](LICENSE) © 2026 Maurizio Morgano.
