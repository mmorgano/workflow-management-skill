# Long-Vision Tracking Layer

Read this reference for activating the `long-vision` management tier, for
status reports, a Risk & Issue register, phase-gates, or the extended closure
checks that come with this tier.

## What this tier is

`long-vision` is an **independent switch**, not a further rung on the
document-size ladder in `references/steering.md` ("Right-Sized Document
Sets"). That ladder (small / medium / large) is never persisted — it is
inferred live from intake and conversation, and stays exactly as it is.
`long-vision` is the one thing in this model that **is** persisted, because it
changes the AI's runtime behavior (which optional artifacts exist, and the
extra closure checks below) in a way that must stay stable across sessions,
not be re-derived every time.

A project can be `large` without `long-vision` (a well-scoped multi-component
project with no need for dated status snapshots or a Risk/Issue register), and
a project can need `long-vision` while its document set stays modest. Judge
the two independently.

## Activation — adaptive, never configured by hand

Extends the existing intake and right-sizing in `references/steering.md`: the
AI evaluates scale and **proposes** the tier; the user confirms. Nothing here
is a manual setting the user is expected to toggle.

**Two detection moments:**

1. **At intake** (or when adopting an existing project into a context): if the
   answers about longevity, multi-component scope, or constraints point to
   long-vision territory, propose the tier by name, not just extra documents.
2. **Emergent**: during ordinary work, watch for escalation signals. When
   enough of them fire, stop and ask.

**Escalation signals:**

- *Strong (any single one is enough to propose):* the user explicitly asks for
  a roadmap, a milestone plan, a status report, or a risk list · two or more
  repos/components in play **with declared dependencies** between them · more
  than one person or a team involved · one or more milestones/phases with
  **formal exit criteria already defined and in active use** (a demo
  criterion, a STOP condition, a phase-gate) — this fires independently of
  team size or repo count, since a solo single-repo project run this way is
  exactly the case dated status snapshots and phase-gates are for.
- *Weak (need two or more together to propose):* the user lists many
  features/deliverables at once · multi-phase or long-horizon language ("first
  ... then ... eventually", "over the next few months") · accumulation over
  time past a rough threshold — the RECAP open-items table growing past
  roughly 15 rows, total tracked tasks past roughly 25 (or open tasks past
  10), more than roughly 15 session files, or a roadmap past 4 phases.

**Activation rules (so it never becomes annoying):**

- Propose, never activate silently. The user confirms.
- Describe the minimal set that would be added, not the whole tracking
  apparatus.
- Start from now: no obligation to backfill history retroactively.
- Record the outcome in `.workflow-config.json`: `management_tier:
  "long-vision"` plus `since` (the real activation date, never backdated).
  Record a decline too (`declined_at` plus the reason), so the AI does not ask
  again every session — only when signals rise markedly further.
- The closure ritual below keys off `management_tier`, never off "does
  directory X exist" — this is what lets the tier stay stable even before its
  optional documents are created (see next section).

## Standard documents — all optional, most created only on first need

| Document | File | Created | Relationship to what already exists |
|---|---|---|---|
| Dated status report | `status/STATUS_YYYY-MM-DD.md` | at activation (first status), then at session close **only if an R4 trigger fires** (below) | A dated, immutable snapshot: health per phase, rollup, done/in progress/next, drift from plan. Forms a history you diff over time. Relationship to `RECAP.md`: see R1–R10 below. |
| Risk & Issue register | `raid/register.md` — one table file | at the **first qualifying item**, not at activation | Only **Risks** (external, not resolvable by the AI) and **Issues** (promoted blockers). Assumptions/Dependencies are opt-in, off by default. Rules BR1–BR9 below. |
| Phase-gate | exit criteria in the phase's section of `roadmap/<slug>-roadmap.md`; the gate record itself is a **confirmed** entry in the decision record (`references/steering.md` § Decision Records), tagged as blocking that phase | exit criteria: when the phase is defined · record: when the phase is crossed | No separate gate file. Crossing a gate is a decision like any other, with its own id. |
| Progress rollup | a section of the status report (derived, not a source of truth) | regenerated with each status | "Phase 2 at 60%, missing X, Y, Z" — computed from tasks done/total per phase. RECAP never states this (R7). |
| Change log | `roadmap/change-log.md` (append-only) | at the first scope/plan change | What changed in the plan, why, impact on phases/dates. Distinct from the decision record, which explains *why* a choice was made. |
| Lessons learned | `roadmap/lessons.md` (append-only) | at the first entry | What to repeat, what not to, dead ends already explored. Distinct from decisions. |
| Closure report | `roadmap/closure-<phase>.md` | at phase/project closure | Delivered vs. promised; links to lessons and the last status. |

## Principle: the AI resolves, it does not archive

Facing a snag, the AI's default is to try to resolve it, or note it as a next
step. It is elevated to a tracked Issue only when it genuinely does not close
quickly. AI assistance shortens resolution time — much of what a traditional
PM would track as an "issue" dies inside a single session. Keep the Risk &
Issue register small and lazy: created at first real need, with a high bar for
entry.

## `RECAP.md` ↔ dated status — R1–R10

`RECAP.md` stays a hand-maintained **live state** (open items and the concrete
next step); the dated status is the **immutable historical series**. Neither
states the other's facts.

| Fact | Owner | The other file |
|---|---|---|
| Health per phase, % progress, rollup | **STATUS** | RECAP links, never states |
| Drift from plan (slipping dates) | **STATUS** | RECAP links |
| "Done / in progress / next" as of a date | **STATUS** (snapshot) | — |
| Open items right now | **RECAP** | STATUS summarizes *as of* its date |
| The concrete next step | **RECAP** | LAST_SESSION echoes it |
| Blockers / issues | **`raid/register.md`** | RECAP links, STATUS counts |
| Decisions | **the decision record** | both link |

- **R1** — RECAP never contains numbers (health, %, target dates). Only the
  pointer line. A health number appearing in RECAP is a mistake to fix.
- **R2** — Only one status is "current": the most recent by date. Older ones
  are immutable history; corrections are allowed only until the next session
  closes, then frozen.
- **R3** — A status is a snapshot: no relative references, no "updated on...".
  Never edit an old status; create a new one.
- **R4** — Mandatory creation cadence. A new status is created at session
  close **if and only if**: (a) a phase's health changed, **or** (b) a
  phase-gate was crossed, **or** (c) more than one sprint has passed since the
  last one, **or** (d) there is a new change-log entry. Otherwise, no status
  that day.
- **R5** — Every status has a mandatory "What changed since `STATUS_<prev>`"
  section. If nothing changed, it is not created (R4).
- **R6** — A single pointer line at the top of RECAP:
  `🟡 Amber (Phase 2) — status/STATUS_2026-09-10.md`. Health in **one word,
  copied** from the latest status. The only place RECAP names health.
- **R7** — Rollups live only in the status. RECAP says "Phase 2 in progress",
  not the percentages.
- **R8** — Consistency check at closure: (1) if a status was created today,
  the RECAP pointer line is updated; (2) no number has crept back into RECAP;
  (3) the status RECAP references is the latest by date.
- **R9** — A divergence is **surfaced to the user, not silently fixed** (RECAP
  could be right and the status stale, or the other way round).
- **R10** — One writer per field.

**STATUS template:**

```
# Status YYYY-MM-DD

- Sprint <id> · Current phase: N — <name>
- Overall health: 🟢/🟡/🔴 — <one-line reason>

## Health per phase
| Phase | State | Health | % | Notes |

## Progress rollup
- Phase N: <done>/<total> tasks — missing: X, Y, Z

## Drift from plan
- <milestone> slips from <date> to <date> — cause

## What changed since STATUS_<prev>
- ...

## RAID summary
- Open high risks: n · Issues/blockers: n → raid/register.md

## Done / In progress / Next (as of YYYY-MM-DD)
```

## Blockers ↔ Risk & Issue register — BR1–BR9

- **BR1** — A session's `## Blocker` section is transient ("what blocks me
  right now"). Not authoritative at project level.
- **BR2** — Promotion: at session close, any blocker that (a) survives the
  session **and** (b) does not resolve with "do X next time" **and** (c) needs
  an owner or a plan → the AI **proposes** promoting it to an Issue in
  `raid/register.md`. The user confirms.
- **BR3** — `raid/register.md` is the **only** authoritative register of
  tracked blockers at `long-vision`. No parallel list elsewhere.
- **BR4** — RECAP: no blocker list, one pointer line with counts copied from
  the register's summary (like R6).
- **BR5** — Sprint records: no standalone list; only an id plus one line of
  Issues touching that sprint.
- **BR6** — A blocked task reads `Blocked by: raid/I-03`. An inline "waiting
  on..." note is fine for under one session; if it persists, promote it.
- **BR7** — A register entry has: id, type (Risk/Issue), description, owner,
  impact, mitigation/plan, state (open/mitigating/resolved), closure date and
  method. Resolved entries stay (append-only in spirit).
- **BR8** — Closure check: every open Issue is referenced by a task, a phase,
  or has a stated next step; no orphan Issues. RECAP counts match the register
  (otherwise, per R9: surface it, do not silently fix).
- **BR9** — A Risk that materializes **converts** into an Issue (a new Issue
  entry; the Risk is marked "materialized → I-NN"), never edited in place.
- **Entry bar for Risks**: only real, **external** risks the AI cannot resolve
  itself ("the upstream PR is not merging", "the client has not approved
  scope"). Assumptions and Dependencies: opt-in, off by default.

## Closure ritual — one procedure for everyone

The closure ritual is **identical regardless of declared project size**: at
every close, check each artifact that is actually enabled in this context and
act only if the current state calls for it. There is no separate "heavy"
ritual reserved for large projects — a `long-vision` context with nothing open
this session does close exactly like a `light` one; it just has more optional
artifacts that *could* need an action.

When `management_tier` is `long-vision`, `references/sessions.md` § Close adds
these checks, each conditional on state, not on size:

1. Check the R4 triggers; if one fired, create the new dated status.
2. Apply BR2: propose promoting any blocker that survived the session to an
   Issue.
3. Review any focus notes touched this session: is there a decision node
   mature enough (a concrete default proposal, awaiting confirmation) to move
   into the decision record as a `proposed` entry, per
   `references/steering.md` § Decision Records? If so, propose the move — do
   not leave it sitting only in the focus note.
4. Run the R8/BR8 consistency checks. Surface any divergence per R9; never
   silently correct it.

## Adopting this tier on an already-started project

Never do a bulk, retroactive rewrite of existing documents — that fights the
decision record's append-only nature and the "resolve, don't archive"
principle above. Instead:

1. Add the prefix-to-file index (see `references/steering.md` § Decision
   Records) once, at adoption time — cheap, immediate benefit, touches no
   existing content.
2. Move (not copy) only decision nodes that are **still open** — found in
   focus notes or elsewhere, not yet confirmed — into the decision record as
   `proposed` entries. They are live work, not history.
3. Leave already-closed/confirmed material exactly where it is, unformatted.
   It is history.

The natural moment for this small reshuffle is the same moment the tier gets
adopted (the adaptive activation above) — they coincide.
