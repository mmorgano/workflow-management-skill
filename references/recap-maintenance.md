# RECAP Maintenance

Read this reference when `RECAP.md`, `tasks/INDEX.md`, or another operational
workflow view has grown large enough to hurt context use.

The goal is a small operational view with recoverable history, not data loss.

## Purpose

`RECAP.md` is an operational dashboard. It should show current work, active
blockers, near-term next steps, and links to detailed records. It should not
become the complete history of every closed task or decision.

Detailed history belongs in:

- `tasks/done/`;
- `sessions/`;
- `roadmap/` and decision records;
- `archive/recap/` snapshots or history extracts.

## Size Guidance

Use judgment and the project shape, but treat these as default signals:

- **Soft limit:** 30-40 KB. Prefer summarizing closed detail.
- **Hard limit:** 60 KB. Propose maintenance before adding more history.
- **Critical:** 100 KB. Avoid loading or rewriting the whole file until a
  maintenance plan is agreed.

When exact byte size is unavailable, use rough equivalents: hundreds of lines,
long closed-task tables, or repeated historical sections are enough to trigger
maintenance.

## Maintenance Preconditions

Before changing files:

1. read `.workflow-config.json`;
2. confirm maintenance is allowed when a `recap_maintenance.enabled` setting is
   present;
3. inspect `RECAP.md`, `tasks/INDEX.md`, and the relevant task/session records;
4. make a recoverable snapshot under `archive/recap/`;
5. ask for confirmation before broad rewrites, archival moves, or any deletion.

Do not permanently delete history as part of ordinary maintenance.

## Invariants

These rules hold for every project and cannot be changed by configuration:

- **Open work is never moved out of `RECAP.md`.** Every task that is not
  completed stays in the operational view. After maintenance, the number of open
  tasks must be the same as before; if it differs, stop and report it.
- Nothing is deleted. Everything that leaves `RECAP.md` is preserved in the
  snapshot and in the archive files.
- Task numbers are never changed or reused.

Everything else below is a default that a project can adjust.

## Suggested Configuration

Projects may add this optional section to `.workflow-config.json`:

```json
{
  "recap_maintenance": {
    "enabled": true,
    "soft_limit_kb": 40,
    "hard_limit_kb": 60,
    "critical_limit_kb": 100,
    "keep_recent_completed": 10,
    "keep_recent_days": null,
    "archive_closed_sections": true
  }
}
```

When this section is absent, maintenance is still allowed by user request, but
use the default size guidance above.

"Recently completed" is defined by count (`keep_recent_completed`, default 10).
Set `keep_recent_days` to a number of days to define it by age instead, for
example `28`; when both are set, keep an item if either criterion keeps it. A
project may change these values freely; the invariants above still apply.

## Rotation Pattern

Prefer conservative rotation:

1. Create `archive/recap/` if missing.
2. Save a timestamped snapshot of the original `RECAP.md`.
3. Move closed or historical detail into a dated history file such as
   `archive/recap/2026-09-recap-history.md`.
4. Keep the current `RECAP.md` focused on open work, active risks, near-term
   next steps, and links to archived history.
5. Preserve task numbers and links. Do not renumber tasks.
6. In a section that mixes open and completed items, move only the completed
   detail that is no longer recent; the section and its open items stay.
7. Keep enough "recently completed" items to maintain continuity, usually the
   latest 5-10 completed tasks or whatever the project config requests.

## Target RECAP Shape

A maintained `RECAP.md` should usually contain:

- title and last-maintained note;
- current focus;
- open tasks grouped by area;
- active blockers or risks;
- recently completed items, short and linked;
- links to recap history archives and detailed records.

Avoid copying long task narratives into `RECAP.md` when `tasks/done/NN-*.md`
or session records already contain them.

## `tasks/INDEX.md`

`tasks/INDEX.md` remains the source of task numbering. Do not compress it in a
way that loses assigned numbers or makes the next number ambiguous.

If it becomes too large, split only the historical listing while preserving:

- the next task number;
- all currently open task entries;
- links to archived index ranges;
- a clear note that archived entries must not be reused.

## Reporting

After maintenance, report:

- original size and new size when available;
- archive files created;
- what remains in the operational view;
- anything intentionally left unverified.

