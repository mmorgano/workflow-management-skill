#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT
OLD_DATE="$(python3 - <<'PY'
from datetime import date, timedelta
print((date.today() - timedelta(days=90)).isoformat())
PY
)"
SECOND_DATE="$(python3 - "$OLD_DATE" <<'PY'
from datetime import date, timedelta
import sys
print((date.fromisoformat(sys.argv[1]) + timedelta(days=1)).isoformat())
PY
)"

bash -n "$ROOT/setup-skills.sh"
bash -n "$ROOT/compact-sessions.sh"
bash -n "$ROOT/sync-codex-package.sh"
bash -n "$ROOT/packages/codex/workflow-management/setup-skills.sh"
bash -n "$ROOT/packages/codex/workflow-management/compact-sessions.sh"
test -f "$ROOT/references/steering.md"
test -f "$ROOT/references/tracking.md"

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

# Existing configuration must be protected unless replacement is explicit.
if XDG_CONFIG_HOME="$TMP/setup-config" "$ROOT/setup-skills.sh" --path "$SETUP_CONTEXT"; then
    echo "Setup replaced an existing configuration without --force" >&2
    exit 1
fi
XDG_CONFIG_HOME="$TMP/setup-config" "$ROOT/setup-skills.sh" --force --record-language Italian --path "$SETUP_CONTEXT"
python3 - "$SETUP_CONTEXT/.workflow-config.json" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)
assert config["record_language"] == "Italian"
PY

OTHER_CONTEXT="$TMP/other-context"
if XDG_CONFIG_HOME="$TMP/setup-config" "$ROOT/setup-skills.sh" --path "$OTHER_CONTEXT"; then
    echo "Setup replaced a pointer to a different context without --force" >&2
    exit 1
fi
test ! -e "$OTHER_CONTEXT"

# --here scaffolds a per-project context without reading or writing the pointer.
HERE_CONFIG="$TMP/here-config"
HERE_CONTEXT="$TMP/ai_context_project"
XDG_CONFIG_HOME="$HERE_CONFIG" "$ROOT/setup-skills.sh" --path "$HERE_CONTEXT" --here --record-language English \
    > "$TMP/here-output.txt"
test -f "$HERE_CONTEXT/.workflow-config.json"
test -d "$HERE_CONTEXT/sessions/archive"
test -d "$HERE_CONTEXT/tasks/todo"
test ! -e "$HERE_CONFIG"
grep -Fq '"folders"' "$TMP/here-output.txt"
grep -Fq "$HERE_CONTEXT" "$TMP/here-output.txt"
# A pre-existing pointer to another context does not block --here and is left
# untouched.
mkdir -p "$TMP/existing-pointer/skill-workflow-management"
PRESET_POINTER="$TMP/existing-pointer/skill-workflow-management/context-path.json"
printf '{"ai_context_root":"%s"}\n' "$SETUP_CONTEXT" > "$PRESET_POINTER"
XDG_CONFIG_HOME="$TMP/existing-pointer" "$ROOT/setup-skills.sh" --path "$TMP/ai_context_second" --here >/dev/null
test -f "$TMP/ai_context_second/.workflow-config.json"
python3 - "$PRESET_POINTER" "$SETUP_CONTEXT" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    assert json.load(handle)["ai_context_root"] == sys.argv[2], "--here must not rewrite the pointer"
PY

# The installable Codex package must stay synchronized and expose one skill.
PACKAGE="$ROOT/packages/codex/workflow-management"
"$ROOT/sync-codex-package.sh" --check
test -x "$PACKAGE/setup-skills.sh"
test -x "$PACKAGE/compact-sessions.sh"
test -f "$PACKAGE/agents/openai.yaml"
grep -Fq 'display_name: "Workflow Management"' "$PACKAGE/agents/openai.yaml"
grep -Fq '$workflow-management' "$PACKAGE/agents/openai.yaml"
test "$(find "$PACKAGE" -name SKILL.md -type f | wc -l)" -eq 1
test -f "$PACKAGE/references/steering.md"
test -f "$PACKAGE/references/tracking.md"

# The repository root is the Claude Code skill; there is no adapters/ tree.
test ! -e "$ROOT/adapters"
grep -Eq '^name: workflow-management[[:space:]]*$' "$ROOT/SKILL.md"

test ! -e "$ROOT/examples/basic-ai-context/LAST_SESSION.md"
test ! -e "$PACKAGE/examples/basic-ai-context/LAST_SESSION.md"

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

# The map form of the pointer resolves through "default" outside a workspace.
cat > "$TMP/skill-workflow-management/context-path.json" <<EOF
{"contexts":{"/some/workspace":"/nonexistent"},"default":"$TMP/context"}
EOF
XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh" --dry-run > "$TMP/dry-run-map.txt"
grep -Fq "sprint-$OLD_DATE" "$TMP/dry-run-map.txt"
cat > "$TMP/skill-workflow-management/context-path.json" <<EOF
{"ai_context_root":"$TMP/context"}
EOF

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
