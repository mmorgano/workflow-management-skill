# Session Compaction

Read this reference when reviewing retention or compacting session records.

## Preconditions

- Read `.workflow-config.json` and stop when compaction is disabled.
- Use `compact-sessions.sh`; it requires Bash, Python 3, `zip`, and `unzip`.
- Prefer `bash ./compact-sessions.sh --dry-run` and review the affected files.
- Obtain explicit confirmation before running real compaction.

## Retention behavior

The configured `compaction.retention_days` is a requested minimum, not always
the effective cutoff. The script protects at least 25 recent days. When sprints
are enabled, it also protects the current and previous sprint:

```text
effective retention = max(configured days, 25, 2 × sprint duration in days)
```

Archived sessions are grouped by month or sprint according to
`compaction.group_by`.

## Recovery and deletion

Real compaction builds a summary and ZIP archive, verifies the ZIP, and only
then moves source sessions under `sessions/archive/originals/`. Incremental
compaction preserves previously archived source files and summary rows.

Permanent deletion occurs only with `--delete-originals` and only after ZIP
verification. Never add that option without explicit user authorization.
