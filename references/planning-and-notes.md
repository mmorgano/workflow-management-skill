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
