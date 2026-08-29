#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
OLD_DATE="$(date -d '90 days ago' +%F)"
SECOND_DATE="$(date -d "$OLD_DATE + 1 day" +%F)"

bash -n "$ROOT/setup-skills.sh"
bash -n "$ROOT/compact-sessions.sh"

# Non-interactive setup must create the portable runtime configuration.
SETUP_CONTEXT="$TMP/setup context's"
XDG_CONFIG_HOME="$TMP/setup-config" "$ROOT/setup-skills.sh" --path "$SETUP_CONTEXT" --record-language English
python3 - "$SETUP_CONTEXT/.workflow-config.json" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)
assert config["ai_context_root"].endswith("setup context's")
assert config["compaction"]["enabled"] is True
assert config["record_language"] == "English"
PY

# Setup creates configuration and directories, while the agent creates
# operational Markdown records on first session start.
test ! -e "$SETUP_CONTEXT/RECAP.md"
test ! -e "$SETUP_CONTEXT/LAST_SESSION.md"
test ! -e "$SETUP_CONTEXT/tasks/INDEX.md"

# The installable Codex package must stay synchronized and expose one skill.
PACKAGE="$ROOT/packages/codex/workflow-management"
for file in CORE.md conventions.md setup-skills.sh setup-skills.ps1 compact-sessions.sh; do
    cmp "$ROOT/$file" "$PACKAGE/$file"
done
test "$(find "$PACKAGE" -name SKILL.md -type f | wc -l)" -eq 1
test ! -e "$ROOT/adapters/codex/SKILL.md"

mkdir -p "$TMP/context/sessions" "$TMP/skill-workflow-management"
cat > "$TMP/context/.workflow-config.json" <<EOF
{"ai_context_root":"$TMP/context","sprint":{"enabled":true,"duration_weeks":2},"compaction":{"enabled":true,"retention_days":7,"group_by":"sprint"}}
EOF
cat > "$TMP/skill-workflow-management/context-path.json" <<EOF
{"ai_context_root":"$TMP/context"}
EOF
cat > "$TMP/context/sessions/SESSION_${OLD_DATE}.md" <<EOF
## Current sprint
- **Sprint ID**: $OLD_DATE
## Travail effectué
<!-- workflow:work-done -->
- Test
EOF

XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh" --dry-run > "$TMP/dry-run.txt"
grep -Fq "sprint-$OLD_DATE" "$TMP/dry-run.txt"

# English template headings must make it into the real archive recap.
XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh"
grep -Fq "| $OLD_DATE | Test |" "$TMP/context/sessions/archive/sprint-$OLD_DATE.md"
unzip -tqq "$TMP/context/sessions/archive/sprint-$OLD_DATE.zip"
test -f "$TMP/context/sessions/archive/originals/sprint-$OLD_DATE/SESSION_${OLD_DATE}.md"

# A later compaction for the same group must keep both archive summaries and
# source files rather than overwriting the earlier result.
cat > "$TMP/context/sessions/SESSION_${SECOND_DATE}.md" <<EOF
## Current sprint
- **Sprint ID**: $OLD_DATE
## Work done
- Follow-up | with table character
EOF
XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh"
grep -Fq "| $OLD_DATE | Test |" "$TMP/context/sessions/archive/sprint-$OLD_DATE.md"
grep -Fq "| $SECOND_DATE | Follow-up \\| with table character |" "$TMP/context/sessions/archive/sprint-$OLD_DATE.md"
unzip -tqq "$TMP/context/sessions/archive/sprint-$OLD_DATE.zip"
test -f "$TMP/context/sessions/archive/originals/sprint-$OLD_DATE/SESSION_${SECOND_DATE}.md"

# Invalid numeric configuration must fail safely rather than be evaluated.
cat > "$TMP/context/.workflow-config.json" <<EOF
{"ai_context_root":"$TMP/context","sprint":{"enabled":true,"duration_weeks":2},"compaction":{"enabled":true,"retention_days":"bad","group_by":"sprint"}}
EOF
if XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh" --dry-run; then
    echo "Invalid configuration was accepted" >&2
    exit 1
fi

echo "Smoke tests passed"
