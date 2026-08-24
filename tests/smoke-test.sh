#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash -n "$ROOT/setup-skills.sh"
bash -n "$ROOT/compact-sessions.sh"

# Non-interactive setup must create the portable runtime configuration.
SETUP_CONTEXT="$TMP/setup context's"
XDG_CONFIG_HOME="$TMP/setup-config" "$ROOT/setup-skills.sh" --path "$SETUP_CONTEXT"
python3 - "$SETUP_CONTEXT/.workflow-config.json" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)
assert config["ai_context_root"].endswith("setup context's")
assert config["compaction"]["enabled"] is True
PY

mkdir -p "$TMP/context/sessions" "$TMP/skill-workflow-management"
cat > "$TMP/context/.workflow-config.json" <<EOF
{"ai_context_root":"$TMP/context","sprint":{"enabled":true,"duration_weeks":2},"compaction":{"enabled":true,"retention_days":7,"group_by":"sprint"}}
EOF
cat > "$TMP/skill-workflow-management/context-path.json" <<EOF
{"ai_context_root":"$TMP/context"}
EOF
cat > "$TMP/context/sessions/SESSION_2026-07-01.md" <<'EOF'
## Current sprint
- **Sprint ID**: 2026-07-01
## Work done
- Test
EOF

XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh" --dry-run | grep -q 'sprint-2026-07-01'

# English template headings must make it into the real archive recap.
XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh"
grep -Fq '| 2026-07-01 | Test |' "$TMP/context/sessions/archive/sprint-2026-07-01.md"
unzip -tqq "$TMP/context/sessions/archive/sprint-2026-07-01.zip"
test -f "$TMP/context/sessions/archive/originals/sprint-2026-07-01/SESSION_2026-07-01.md"

# A later compaction for the same group must keep both archive summaries and
# source files rather than overwriting the earlier result.
cat > "$TMP/context/sessions/SESSION_2026-07-02.md" <<'EOF'
## Work done
- Follow-up | with table character
EOF
XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh"
grep -Fq '| 2026-07-01 | Test |' "$TMP/context/sessions/archive/sprint-2026-07-01.md"
grep -Fq '| 2026-07-02 | Follow-up \| with table character |' "$TMP/context/sessions/archive/sprint-2026-07-01.md"
unzip -tqq "$TMP/context/sessions/archive/sprint-2026-07-01.zip"
test -f "$TMP/context/sessions/archive/originals/sprint-2026-07-01/SESSION_2026-07-02.md"

# Invalid numeric configuration must fail safely rather than be evaluated.
cat > "$TMP/context/.workflow-config.json" <<EOF
{"ai_context_root":"$TMP/context","sprint":{"enabled":true,"duration_weeks":2},"compaction":{"enabled":true,"retention_days":"bad","group_by":"sprint"}}
EOF
if XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh" --dry-run; then
    echo "Invalid configuration was accepted" >&2
    exit 1
fi

echo "Smoke tests passed"
