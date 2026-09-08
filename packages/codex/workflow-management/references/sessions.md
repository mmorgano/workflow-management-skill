# Session Lifecycle

Read this reference when starting, resuming, checkpointing, or closing a work
session.

## When no context resolves

If the resolution order in `CORE.md` finds no context (no workspace root and no
working-directory `.workflow-config.json`, and `context-path.json` is absent or
has no matching entry and no `default`), do not fall back to an arbitrary
directory, and do not offer to attach one of the other contexts on the machine —
those belong to other workspaces. The default action here is to create a new
context for this workspace. Before asking for a path, offer that:

1. Propose a directory name, taking the first available of: the `.code-workspace`
   file name without its extension, the main project folder of the workspace,
   or the current directory name — as `ai_context_<name>`. Propose a location
   beside the project. Show both and let the user change them; never create
   silently.
2. On confirmation, run the setup script with the per-project flag —
   `setup-skills.ps1 -ContextRoot <path> -Here` or
   `bash setup-skills.sh --path <path> --here` — so the context is attached
   through the workspace and not the machine-wide pointer.
3. Print the `folders` snippet the setup script emits and ask the user to add
   the directory to the `.code-workspace` file and reload the window. Do not
   edit the `.code-workspace` file yourself.
4. Continue with first-use initialization below.

If the user declines, ask for an existing context path or proceed without
workflow records for this request. Attach an existing context only when the
user names it; do not propose one yourself.

## First-use initialization

After resolving a valid configuration, create only missing operational records:

- `RECAP.md` with an empty open-work table;
- `tasks/INDEX.md` with the next available number set to `1`;
- the current sprint file when sprints are enabled and no sprint covers the
  current date;
- `sessions/SESSION_YYYY-MM-DD.md` for the current date.

Never overwrite an existing record during initialization. Do not create
`LAST_SESSION.md` before the first session is closed; its absence means there
is no previous session.

## Session record

Use one session file per working day. Include work done, decisions, blockers,
active focus, next steps, and a timesheet. Include the sprint identifier and
period when sprints are enabled.

Visible headings and prose use `record_language`. Place the language-neutral
marker `<!-- workflow:work-done -->` immediately before the work-done bullet
list so compaction can summarize records in any configured language.

## Start or resume

1. Verify the current date from a reliable runtime source; do not guess it.
2. Resolve `<AI_CONTEXT_ROOT>` and read `.workflow-config.json`. If nothing
   resolves, follow "When no context resolves" above. Do not read `RECAP.md`,
   `LAST_SESSION.md`, or any session, task, or sprint record until the root is
   resolved — reading them commits the session to that context.
3. Initialize missing first-use records.
4. Read `RECAP.md`, `LAST_SESSION.md` when present, and the current sprint when
   enabled.
5. Create today's session file only when it is missing.
6. Present a concise summary of the current sprint, open work, blockers, and
   next steps.

## Checkpoints

Update the current session when the work produces a durable decision, blocker,
completed step, or changed next action. Do not log inconsequential tool-by-tool
activity.

## Close

1. Finalize the current session, including next steps and timesheet.
2. Create or update `LAST_SESSION.md` as a short pointer to the session file.
3. Update `RECAP.md` when open work changed.
4. Update the active sprint when its tickets, blockers, or decisions changed.

`LAST_SESSION.md` should contain the date, session file, relevant branches or
projects, a one-line state summary, and the next priority. Translate visible
labels using `record_language`.
