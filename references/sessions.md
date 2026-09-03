# Session Lifecycle

Read this reference when starting, resuming, checkpointing, or closing a work
session.

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
2. Resolve `<AI_CONTEXT_ROOT>` and read `.workflow-config.json`.
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
