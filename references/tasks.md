# Tasks and RECAP

Read this reference when creating, planning, progressing, completing, or
reviewing workflow tasks, or when updating `RECAP.md`.

## Task numbering

`tasks/INDEX.md` is the source of truth for task numbers. Read it before
creating a task, assign the next available number exactly once, register the
new task, and increment the number. Never infer the next number from filenames
and never reuse a number.

Store open tasks under `tasks/todo/` and completed tasks under `tasks/done/`.
Use a name such as `NN-descriptive-slug.md`.

## Task record

A task record should contain the goal, current state, relevant impact and risk,
an execution plan when useful, success criteria, references, and progress.
Keep the structure proportional to the task rather than filling sections with
placeholder text.

## Lifecycle

1. Analyze the request and relevant project context.
2. Record a plan when the work is non-trivial or must survive the conversation.
3. Ask for approval when the plan contains destructive, externally mutating,
   hard-to-reverse, or genuinely decision-dependent steps.
4. Execute only the scope the user authorized and update meaningful progress.
5. Run project-appropriate verification and record the outcome.
6. Move the task to `tasks/done/` when its success criteria are met.

Use a safety checkpoint only when rollback risk justifies one. Choose a method
that fits the project and current permissions; a Git tag or backup is not a
universal requirement.

## RECAP

`RECAP.md` is the compiled view of open work. Group items by a useful project
or area, keep status and blockers current, and update it when task state or
priority changes. Link task files instead of duplicating their full plans.
