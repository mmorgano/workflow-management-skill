---
name: workflow-management
description: Structured daily work sessions, tasks, sprints, focus topics, meeting outcomes, roadmaps, RECAP tracking, and recoverable session archives for durable project context. Use when starting or closing a work session, managing a task, sprint, focus topic, meeting outcome, or roadmap, checking project status, or compacting old session records.
---

# Workflow Management for Claude Code

Use this skill when the user asks to start or close a work session, manage
tasks or sprints, update a RECAP, resume project context, or compact old
session records. Also use it to track a focus topic, capture durable meeting
outcomes, or plan and review a roadmap.

Read `CORE.md` and `conventions.md` in this skill package before changing the
workflow context. Follow their shared contract exactly.

## Install

Claude Code loads a skill from `SKILL.md` at the root of its skill folder,
and the folder name must match the `name` field above (`workflow-management`).

- **Personal** (available in every project): copy this repository's contents
  into `~/.claude/skills/workflow-management/`, then replace the copied root
  `SKILL.md` (the Kiro adapter) with this file, renamed to `SKILL.md`.
- **Project** (checked into the repo, shared with the team): same layout
  under `<project>/.claude/skills/workflow-management/`.

Either way, `CORE.md`, `conventions.md`, `setup-skills.sh`, and
`compact-sessions.sh` must sit alongside the installed `SKILL.md` — the
adapter refers to them as siblings, not by absolute path.

## Configuration

The runtime configuration is `<AI_CONTEXT_ROOT>/.workflow-config.json`. The
user can initialize it with `setup-skills.sh`; on Windows this requires WSL or
Git Bash with Python 3, `zip`, and `unzip` available in that shell (see the
repository README for details).

## Claude Code behavior

- Claude Code invokes this skill automatically when a request matches the
  description above, or explicitly if the user references it by name.
- At session start, verify the current date before creating or naming any
  file — never guess it.
- `tasks/INDEX.md` under `AI_CONTEXT_ROOT` is the durable, cross-session
  source of truth for task numbering. Claude Code's own in-session task
  tracker (TaskCreate/TaskUpdate) is for tracking steps within the current
  conversation only; it does not replace or renumber entries in
  `tasks/INDEX.md`.
- Treat the context directory as user data: inspect it before changing it,
  and never delete or overwrite session, task, or RECAP files outside the
  compaction flow below.
- Ask for explicit confirmation before compaction, deleting files, external
  publication (e.g. `git push`, opening a PR), or any non-trivial execution
  plan — consistent with this harness's own rules on hard-to-reverse actions.
- Prefer `compact-sessions.sh --dry-run` before a real compaction, and never
  run a real compaction without the user's confirmation.
- Report what was verified and what remains unverified after each task.

## Manual test

Before relying on this adapter, confirm it end-to-end against a scratch
context directory (not a real `AI_CONTEXT_ROOT`):

1. Run `setup-skills.sh --path <scratch-dir>` to create a throwaway
   configuration and directory layout.
2. Ask Claude Code to start a session. Confirm it reads the config, `RECAP.md`,
   `LAST_SESSION.md`, and the sprint file when enabled, then creates
   `sessions/SESSION_<today>.md` and summarizes open tasks/blockers/next steps.
3. Ask it to create a task. Confirm it reads `tasks/INDEX.md` for the next
   number, writes `tasks/todo/NN-slug.md`, and updates the index.
4. Ask it to close the session. Confirm the update order: session file first,
   then `LAST_SESSION.md`, then `RECAP.md`.
5. Ask it to compact sessions. Confirm it runs
   `compact-sessions.sh --dry-run` first and does not run a real compaction
   without explicit confirmation.

## Language and integrations

Default documentation and templates are English; teams may choose the
language of session content (see `conventions.md`). When an issue tracker is
used, verify transitions and ask before changing an external ticket.
