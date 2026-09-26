# Session Lifecycle

Read this reference when starting, resuming, checkpointing, or closing a work
session.

## When no context resolves

If the resolution order in `CORE.md` finds no context (no workspace root and no
working-directory `.workflow-config.json`, and `context-path.json` is absent or
has no matching entry and no `default`), do not fall back to an arbitrary
directory, and do not offer to attach one of the other contexts on the machine —
those belong to other workspaces. The default action here is to create a new
context for this workspace. Before proposing it, run the skippable first-run
introduction in `references/onboarding.md`. It applies only when no context
resolves at all; a context that exists but is unreadable is reported instead,
never introduced again. Before asking for a path, offer that:

0. When the workspace is empty or otherwise looks like a project that does not
   exist yet — not merely an existing project without a context so far — open
   with a short framing pass instead of going straight to a directory name:
   what it is, why it matters, how it will be judged successful, how
   long-lived it is, whether it is a single component or several, and any
   constraint that must shape decisions (privacy, licensing, client
   boundaries, publication limits, compliance, technology goals). One
   conversation answers three needs at once: it is the project intake
   (`references/steering.md`), it feeds the scale assessment for the
   `long-vision` tier (`references/tracking.md`), and it tells you whether
   this is one project or several before any folder is created. Then, before
   scaffolding folders, git, or dependencies, walk `references/bootstrap.md`
   for the non-code traps (naming, git identity, legal/IP, dependencies
   between your own components, licensing) — ask only what this project's
   shape actually raises.
1. Propose a directory name, taking the first available of: the `.code-workspace`
   file name without its extension, the main project folder of the workspace,
   or the current directory name — as `ai_context_<name>`. Propose a location
   the same way: beside the `.code-workspace` file when the workspace is saved,
   otherwise beside the workspace's main folder — and always outside the
   project's own repository. When no folder is open, propose it in the current
   working directory and say that this is a guess to confirm. Show name and
   location and let the user change them; never create silently.
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

When a new context is for a substantial project, offer the project intake in
`references/steering.md` after creating the missing operational records. Use the
answers to propose a right-sized steering set; create steering documents only
after the user accepts the recommendation.

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
   enabled. When RECAP or a decision record points to steering documents, read
   them in the stated order and summarize the project state before selecting a
   focus.
5. Create today's session file only when it is missing.
6. Present a concise summary of the current sprint, open work, blockers, and
   next steps. For steered projects, also include the current phase, what is
   done, what is missing, and the natural next step; then decide the session
   focus with the user.

Starting a session reads and summarizes; it does not repair. If a record looks
stale or inconsistent (for example a task marked "to do" that other records
show as done), say so in the summary and ask before changing it. The only files
created at start are the first-use records and today's session file.

Write the summary as a person would say it: a short greeting, a few plain
sentences, and one clear question about what to work on today. Use a list only
when there are several parallel items, and name files by their short name
rather than their full path.

## Checkpoints

Update the current session when the work produces a durable decision, blocker,
completed step, or changed next action. Do not log inconsequential tool-by-tool
activity.

## Close

1. Finalize the current session, including next steps and timesheet.
2. Create or update `LAST_SESSION.md` as a short pointer to the session file.
3. Update `RECAP.md` when open work changed.
4. Update the active sprint when its tickets, blockers, or decisions changed.
5. Update roadmap, vision, or decision records when phases, direction,
   constraints, or durable decisions changed.
6. When `management_tier` is `long-vision`, also run the closure checks in
   `references/tracking.md` § Closure ritual (status trigger, blocker
   promotion, focus-to-decision promotion, consistency check). These are
   additional conditional checks, not a heavier version of steps 1-5 above —
   at every other tier, close ends at step 5.

`LAST_SESSION.md` should contain the date, session file, relevant branches or
projects, a one-line state summary, and the next priority. Translate visible
labels using `record_language`.
