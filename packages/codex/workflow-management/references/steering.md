# Project Steering

Read this reference when a durable work context needs project-level direction:
project intake, right-sized steering documents, decision records, session
rituals, or documentation hygiene beyond ordinary tasks and RECAP updates.

## Purpose

Workflow records should help an assistant and a human resume the project without
reconstructing its purpose from chat history. Use steering only when the project
has enough duration, uncertainty, or moving parts to justify more than the
standard `RECAP.md`, task files, and session log.

Steering is opt-in and proportional. Do not create extra documents just because
the directories exist, and do not force a large-project structure onto a small
one.

## Project Intake

When creating a new context, or when adopting a substantial existing project
into a context, offer a short intake before proposing documents:

1. What is this project?
2. Why does it matter, and what would make it successful?
3. How long-lived is it: one-off, weeks, months, or ongoing?
4. Is it a single component or a multi-component program?
5. Are there constraints that must shape decisions, such as privacy, licensing,
   client boundaries, publication limits, compliance, or technology goals?

Use the answers to recommend the smallest useful document set. If the user
declines intake, continue with the ordinary workflow records and let steering
emerge later.

## Right-Sized Document Sets

Choose the lightest structure that keeps the project legible:

- **Small or one-off project**: `RECAP.md` plus tasks and sessions. This is
  enough when the goal, order, and constraints fit comfortably in the recap.
- **Medium project**: add `roadmap/<slug>.md` for phases, milestones,
  dependencies, and the current direction beyond one session.
- **Large, long-lived, or multi-component project**: use three levels:
  `roadmap/<slug>-vision.md` for why, goals, principles, scope, and constraints;
  `roadmap/<slug>-roadmap.md` for phases, order, dependencies, and current
  phase; `RECAP.md` for open work and the next concrete step.

For large projects, also consider a decision record when choices need to stay
auditable across sessions.

Independently of this ladder, a project may also switch on the `long-vision`
tracking layer (see `references/tracking.md`) when duration or complexity
crosses certain signals. That switch is orthogonal to document size: it is a
persisted on/off flag, not a fourth, larger rung on this ladder.

## Decision Records

Use an ADR-lite decision record when project direction, architecture, policy, or
constraints change in ways that future sessions must respect.

Recommended file: `roadmap/decision-record.md`, or a project-specific localized
name such as `roadmap/registro-decisioni.md`.

Keep the record append-only:

- each entry has an identifier, date, context, decision, and consequences;
- do not rewrite past entries to change history;
- when a decision changes, add a new entry that supersedes the old one;
- distinguish decided constraints from open questions.

Give each entry a **state**: `proposed` (a concrete default, awaiting
confirmation) → `confirmed` (immutable, as above) → `superseded`. A question
that already has a concrete default proposal is written **directly here** as
`proposed` — it does not pass through a focus note first. Focus notes stay
reasoning and exploration (`references/planning-and-notes.md` § Focus notes);
a decision entry may link to one for background, never the other way round —
a focus note must never be the only place an id lives.

When more than one document owns identifiers (phase numbers, requirement
codes, decision codes), keep a short prefix-to-file index near the top of the
decision record, e.g. "`D-` → this file · `P-` → the phase roadmap · `R-` →
the code repo's own decisions doc". This makes any id traceable without
opening every file, and scales better than encoding the prefix into a
filename, since one file can end up owning more than one id family over time.

**Adopting this on a project that already has history**: never rewrite it in
bulk. (1) Add the prefix index once, at adoption time — cheap, and untouched
content stays untouched. (2) Move (not copy) only decision nodes that are
still **open** — found in a focus note or elsewhere, not yet confirmed — into
this record as `proposed` entries; they are live work, not history. (3) Leave
already-closed, confirmed material exactly where it is, unformatted — it is
history, and rewriting it would fight the append-only rule above.

For substantial projects, keep a "how to resume" section near the top. It should
list the reading order for any assistant or teammate: vision, roadmap, decision
record, RECAP, LAST_SESSION, tasks, and then component-specific documents only
when needed.

## Session Ritual

For projects with steering documents, session start includes a short "state of
the project" pass before choosing work:

1. Read the configured workflow records: `RECAP.md`, `LAST_SESSION.md` when
   present, the current session, and the active sprint when enabled.
2. Read the steering documents named by the RECAP or by the decision record's
   reading order.
3. Summarize the current phase, what is done, what is missing, blockers or
   constraints, and the natural next step.
4. Decide the session focus with the user: advance the current phase, detour,
   consolidate, experiment, or close open loops.

During close, update steering only when durable facts changed. A task completion
usually updates RECAP and the session; a phase change updates the roadmap; a
change of principle, scope, policy, or constraint updates the vision plus a new
decision entry.

## Document Hygiene

Steering documents should stay useful at the top and historical below.

Promote a section into its own document when it grows large enough that it hides
the current state, has its own lifecycle, or is read only for one component.
Merge or demote a document when it no longer carries distinct decisions or
current direction.

Archive inactive documents rather than deleting them when they may explain
history. Use an `archive/` or localized `archivio/` directory with a short
`README.md` that says what moved, why, and where the live replacement is.
Update the RECAP or decision record reading order so future sessions do not
keep opening stale material.

## Cross-References

Link related records instead of duplicating their full contents:

- vision links to roadmap, decision record, and RECAP;
- roadmap links to vision, decision record, active tasks, and component plans;
- decision record links to the live reading order and superseded decisions;
- RECAP links to the task files and the steering documents needed to resume.

Keep assistant-specific instructions out of project steering unless the project
explicitly depends on a tool. Markdown records should remain usable by another
assistant or by a human reading the context directly.
