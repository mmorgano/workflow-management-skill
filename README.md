# Workflow Management

**AI conversations are temporary. Your work shouldn't be.**

Workflow Management is an open-source skill that keeps working context outside
individual AI conversations, in an `ai-context` location you choose. Sessions,
tasks, decisions, project state, planning, meetings and durable knowledge stay
in human-readable files that you can inspect and control.

[MGM Garage Lab](https://mgmgaragelab.com/) ·
[Project website](https://mgmgaragelab.com/workflow-management/) ·
[Overview PDF](docs/workflow-management-overview.pdf) ·
[Get started](#get-started) ·
[Documentation](#documentation)

An open-source project by [MGM Garage Lab](https://mgmgaragelab.com/).

## Pick up the work with its context intact

A project can span many conversations. The next session needs the decisions,
unfinished work and next steps from the previous one. Workflow Management gives
that context a durable home and a consistent way to maintain it.

- **Resume with a clear starting point.** Restore open work, blockers and next steps.
- **Keep the reasoning visible.** Record decisions alongside progress and findings.
- **Carry useful knowledge forward.** Preserve study notes, meeting outcomes and project direction.
- **Keep control of your files.** Read, edit, back up or version the context with your usual tools.

It is especially useful for work that spans sessions, several repositories,
or a change of assistant. For a one-off question with nothing to preserve, the
extra structure may be unnecessary.

## A handoff you can actually read

For a fictional CSV import feature, a session could leave this record:

```markdown
## Decision
Validate every row before writing any records.

## Current state
Validation is implemented. The error report needs clearer line numbers.

## Next step
Add a test for an invalid row, then finish the error report.
```

Close the session, open a new conversation and ask to resume. The assistant
reads the configured context and uses that handoff to establish the next step.
You can open the same files and correct anything that needs attention.

The workflow preserves useful working state. It does not require keeping a
verbatim transcript of every prompt and answer.

## Your context. Your files.

During setup, choose where `ai-context` lives. It can sit alongside the project
as a separate workspace root. Use a shared context across projects when you
want continuity, or separate roots when their histories should remain independent.
For an independent context per project on one machine, see
[per-project contexts](docs/getting-started.md#per-project-contexts-multi-workspace).

```text
Your project workspace
    project/       source code and project documentation
    ai-context/    durable working context you control
```

| Record | What it preserves |
|---|---|
| `RECAP.md` | Current open work, priorities and blockers |
| `sessions/` and `LAST_SESSION.md` | Work done, decisions, next steps and the latest handoff |
| `tasks/` | Numbered work items, plans, progress and verification |
| `sprints/` | Optional short-term goals and planning |
| `focus/` | Study notes, findings and evolving ideas |
| `meetings/` | Outcomes, decisions, owners and follow-ups |
| `roadmap/` | Direction, milestones and dependencies |

Records use Markdown. Runtime configuration uses JSON. The skill requires no
external storage service. Your assistant still needs access to the chosen
location and operates under its own permissions and data-handling settings.

<a id="agent-support"></a>

## Portable across supported assistants

**The workflow belongs to the project, not to the assistant.**

Adapters follow the same [workflow contract](CORE.md). Supported assistants
can resume from the same configured files when they have access to them.
Changing assistants does not require moving the project's working state into
a new conversation.

```text
Codex              Claude Code
     \                 /
       shared workflow contract
                 |
       your chosen ai-context/
```

| Assistant | Current status | Installation |
|---|---|---|
| Codex | Supported package; manual acceptance test documented | [Codex setup](docs/getting-started.md#install-for-codex) |
| Claude Code | Supported adapter; manually tested against a scratch context | [Claude Code setup](SKILL.md#install) |
| Other assistants | Require an adapter implementing the shared contract | [Adapter requirements](CORE.md#adapter-requirements) |

This is file-based portability. It does not provide automatic synchronization
between devices or coordination between assistants editing the same files simultaneously.

## A normal work session

1. **Start:** ask the assistant to start a work session and restore the current context.
2. **Work:** carry out the task and capture useful decisions, progress and findings.
3. **Close:** leave an updated session, recap and concise handoff.
4. **Resume:** continue in a later conversation using the same configured context.

Use natural language. For example:

```text
Let's start a new work session.
Save this decision and the next step.
Close the session and leave a handoff.
```

## Starting something new

The same skill also covers the moment before any of this exists: a new
repository, component, package, or service. Share what you have in mind with
your assistant before scaffolding anything — that one conversation doubles as
the project framing and the context setup, and it surfaces the non-code traps
(naming, git identity, legal/IP, dependencies between your own components)
that are cheap to get right on day one and expensive to fix afterward. See
[`references/bootstrap.md`](references/bootstrap.md).

## Alongside your existing tools

Git preserves source history, Jira tracks issues, and documentation explains
the system. Workflow Management preserves the working context that connects
AI-assisted sessions: what you decided, where you stopped and what comes next.
It complements these tools without replacing them.

## Get started

1. Install the adapter for your assistant using the links in the support table.
2. Run setup and choose your `ai-context` location.
3. Give the assistant access to that location and ask it to start a work session.

<a id="install-for-codex"></a>

For **Codex**, invoke `$skill-installer` with:

```text
Install the skill from https://github.com/mmorgano/workflow-management-skill/tree/main/packages/codex/workflow-management
```

Install only that self-contained package, not the repository root — the root is
the Claude Code skill. Restart Codex if a newly installed version does not appear.

<a id="configure-the-context"></a>

From the cloned repository or installed package, configure the context:

**Windows PowerShell**

```powershell
.\setup-skills.ps1 -ContextRoot C:\projects\ai-context
```

**Linux, macOS, Git Bash or WSL**

```bash
bash ./setup-skills.sh --path /absolute/path/to/ai-context
```

Replace the example path with the location you want. Windows setup is native
PowerShell. Bash setup requires Python 3. Setup creates the configuration and
directories. The assistant creates operational records during the first session.

See [Getting started](docs/getting-started.md) for record language, workspace
configuration, first-use behavior and intentional reconfiguration.

## Documentation

| Guide | Contents |
|---|---|
| [Overview PDF](docs/workflow-management-overview.pdf) | A visual introduction to durable context, project continuity and assistant portability |
| [Getting started](docs/getting-started.md) | Installation, setup and first session |
| [Usage and maintenance](docs/usage-and-maintenance.md) | Full record layout, trigger examples, compaction and verification |
| [Shared contract](CORE.md) and [conventions](conventions.md) | Portable behavior and record rules |
| [Starter context](examples/basic-ai-context/README.md) | A minimal example to inspect |
| [Codex acceptance test](tests/CODEX_ACCEPTANCE.md) | Manual verification in a disposable context |

## Contributing

Improvements to adapters, examples and documentation are welcome. Use
[GitHub issues](https://github.com/mmorgano/workflow-management-skill/issues)
to discuss a problem or proposal. For a code change, run the
[verification checks](docs/usage-and-maintenance.md#verification) and keep
personal context and runtime configuration out of the public repository.

## License

[Apache License 2.0](LICENSE) © 2026 Maurizio Morgano.
