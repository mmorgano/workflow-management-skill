#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

bash -n "$ROOT/setup-skills.sh"
bash -n "$ROOT/compact-sessions.sh"

mkdir -p "$TMP/context/sessions"
cat > "$TMP/config.json" <<EOF
{"ai_context_root":"$TMP/context","sprint":{"enabled":true,"duration_weeks":2},"compaction":{"enabled":true,"retention_days":7,"group_by":"sprint"}}
EOF
cat > "$TMP/context/sessions/SESSION_2026-07-01.md" <<'EOF'
## Current sprint
- **Sprint ID**: 2026-07-01
## Work done
- Test
EOF

XDG_CONFIG_HOME="$TMP" mkdir -p "$TMP/skill-workflow-management"
cp "$TMP/config.json" "$TMP/skill-workflow-management/config.json"
XDG_CONFIG_HOME="$TMP" "$ROOT/compact-sessions.sh" --dry-run | grep -q 'sprint-2026-07-01'
echo "Smoke tests passed"
