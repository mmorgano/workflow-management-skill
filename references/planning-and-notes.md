# Planning and Durable Notes

Read this reference for sprints, focus notes, meeting records, and roadmaps.

## Sprints

Create sprint records only when sprints are enabled. Use the configured
`sprint.duration_weeks` value, which can range from one to six weeks and
defaults to two; never assume every sprint lasts two weeks.

Name a sprint file `sprints/SPRINT_YYYY-MM-DD.md` using its start date. Record
the goal, period, tickets, technical priorities, blockers, decisions, and
notes. Update it only when those durable facts change. When no sprint covers
the current date, create the next sprint according to the configured duration.

Use clear semantic states such as Todo, In progress, Needs information,
Blocked, Done, or Cancelled. Visible labels may be translated using
`record_language`.

## Focus notes

Use `focus/<slug>.md` as an AI-assisted notebook when the user asks to preserve
or resume study notes, evolving analysis, a project idea, or a cross-session
reminder. Derive a clear title and slug when none is provided. Keep the current
understanding near the top and link the note from an active session when useful.
A project idea that is not work yet also gets a line in the parking lot (see
"Parking lot" below), which links the note.

Do not create a focus record for a one-off explanation unless the user asks to
save it or the active workflow clearly requires durable notes.

## Meeting records

Use `meetings/MEETING_YYYY-MM-DD-<slug>.md` when a meeting, call, review, or
decision-making conversation has outcomes that must survive the current
session. Capture purpose, stakeholders, decisions, owners, unresolved items,
and follow-ups. Summarize durable outcomes rather than copying a transcript.

## Roadmaps

Use `roadmap/<slug>.md` for project direction, long-horizon outcomes,
milestones, sequencing, and dependencies beyond one sprint. Keep the current
direction near the top and a dated decision history below it. Link tasks,
sprints, and focus notes instead of duplicating them.

Do not create a roadmap for a single task with no long-horizon implication.

## Active milestone

A project may name one active milestone, never more than one. Propose it when
open work keeps growing without a clear order; the user decides. Record it in
the roadmap file (create `roadmap/<slug>.md` if there is none) with:

- the outcome;
- the done criterion: a concrete, checkable statement;
- what is in scope, as short items or task links.

RECAP names it and links to that section as the current focus. Something
belongs to the milestone when the done criterion cannot be met without it, or
when the user puts it in scope. When the criterion is met, say so and ask what
the next milestone is, if any. Changing or replacing the milestone is the
user's decision. Tasks that already exist outside it stay as they are.

## Parking lot

`roadmap/parking-lot.md` keeps ideas that are worth remembering but are not
work yet. Create it at the first idea. Each idea is one line: date, the idea,
and optionally a link to a focus note. An idea always gets its line here; a
focus note is added only when the idea needs more than one line. Parked ideas have no task number and no
status, and appear in neither RECAP nor `tasks/INDEX.md`.

While a milestone is active, park a new idea outside its scope and say that you
did. Without a milestone, park an idea the user wants to remember but has not
asked to work on. If the user explicitly asks for a task, create it; when it
falls outside the milestone, say so once.

Review the parking lot when a milestone closes or when the user asks. An idea
gets a task number only when the user promotes it. Mark dropped or promoted
ideas instead of deleting them.
