# Codex Acceptance Test

Run this test from a fresh Codex workspace against a disposable context. Do
not use a real work context.

## Install

Install only this GitHub path:

```text
packages/codex/workflow-management
```

Confirm that the installed skill directory contains exactly one `SKILL.md`.
Restart Codex if the skill does not appear after installation.

## Configure

Create a disposable context with `setup-skills.ps1` on Windows or
`setup-skills.sh --path` on POSIX. Confirm that setup creates configuration and
directories but does not create `RECAP.md`, `LAST_SESSION.md`, or
`tasks/INDEX.md`.

## Implicit session start

Open an unrelated, fresh workspace and send this prompt without naming the
skill:

```text
Let's start a new work session.
```

Expected behavior:

1. Codex selects `workflow-management` instead of performing only a general
   workspace analysis.
2. Codex resolves the context from the user-local pointer and reads its
   `.workflow-config.json`.
3. Codex creates `RECAP.md`, `tasks/INDEX.md`, the current sprint when enabled,
   and `sessions/SESSION_<today>.md` without overwriting existing records.
4. Codex does not create `LAST_SESSION.md` yet.
5. Codex reports the sprint, open tasks, blockers, and next steps.

## Task, close, and compaction

1. Ask Codex to create a small test task. Confirm that it reads and updates
   `tasks/INDEX.md` and creates the numbered task file.
2. Ask Codex to close the session. Confirm the update order: session file,
   `LAST_SESSION.md`, `RECAP.md`, then sprint when relevant.
3. Ask Codex to compact sessions. Confirm that it runs a dry-run first and does
   not perform real compaction without explicit confirmation.
