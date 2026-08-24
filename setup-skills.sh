#!/usr/bin/env bash
# setup-skills.sh — Interactive wizard for skill-workflow-management configuration
#
# Usage:
#   ./setup-skills.sh                      # Interactive wizard
#   ./setup-skills.sh --path /abs/path     # Non-interactive: set path only
#
# The wizard configures:
#   1. AI_CONTEXT_ROOT path
#   2. Sprint mode (enabled/disabled, duration)
#   3. Session compaction (retention days, grouping)
#
# Configuration is saved to: <AI_CONTEXT_ROOT>/.workflow-config.json

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FILE="$SKILL_DIR/SKILL.md"

# --- Helpers ---

ask_yes_no() {
    local prompt="$1" default="${2:-n}"
    local yn
    if [[ "$default" == "y" ]]; then
        prompt="$prompt [Y/n]"
    else
        prompt="$prompt [y/N]"
    fi
    read -p "$prompt " yn
    yn="${yn:-$default}"
    [[ "$yn" =~ ^[yY]$ ]]
}

ask_number() {
    local prompt="$1" default="$2" min="$3" max="$4"
    local value
    while true; do
        read -p "$prompt [$default]: " value
        value="${value:-$default}"
        if [[ "$value" =~ ^[0-9]+$ ]] && (( value >= min && value <= max )); then
            echo "$value"
            return
        fi
        echo "  Please enter a number between $min and $max."
    done
}

update_skill_path() {
    local new_path="$1"
    local escaped
    escaped=$(printf '%s\n' "$new_path" | sed 's/[&|]/\\&/g')
    sed -i "s|> \*\*AI_CONTEXT_ROOT\*\*: \`[^\`]*\`|> **AI_CONTEXT_ROOT**: \`${escaped}\`|" "$SKILL_FILE"
}

# --- Non-interactive mode (backward compat) ---

if [[ "${1:-}" == "--path" && -n "${2:-}" ]]; then
    NEW_PATH="$2"
    if [[ "$NEW_PATH" != /* ]]; then
        echo "ERROR: Path must be absolute (start with /). Got: $NEW_PATH"
        exit 1
    fi
    update_skill_path "$NEW_PATH"
    echo "✓ AI_CONTEXT_ROOT updated to: $NEW_PATH"
    exit 0
fi

# --- Interactive wizard ---

echo "╔══════════════════════════════════════════════════════════╗"
echo "║   skill-workflow-management — Configuration Wizard      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Step 1: AI_CONTEXT_ROOT
echo "─── Step 1/3: AI Context Root ───"
echo ""
echo "Where should session files, tasks, and sprint data be stored?"
echo "This must be an absolute path to an existing (or new) directory."
echo ""

current_path=$(sed -n 's/^> \*\*AI_CONTEXT_ROOT\*\*: `\(.*\)`$/\1/p' "$SKILL_FILE" 2>/dev/null | head -1)
if [[ -n "$current_path" ]]; then
    echo "  Current: $current_path"
fi

read -p "AI_CONTEXT_ROOT path: " CTX_ROOT
CTX_ROOT="${CTX_ROOT:-$current_path}"

if [[ "$CTX_ROOT" != /* ]]; then
    echo "ERROR: Path must be absolute. Aborting."
    exit 1
fi

if [[ ! -d "$CTX_ROOT" ]]; then
    if ask_yes_no "Directory does not exist. Create it?" "y"; then
        mkdir -p "$CTX_ROOT"
        echo "  Created: $CTX_ROOT"
    else
        echo "Aborting."
        exit 1
    fi
fi

echo ""

# Step 2: Sprint configuration
echo "─── Step 2/3: Sprint Management ───"
echo ""
echo "Sprints are optional time-boxed planning cycles."
echo "If disabled, session files won't reference sprints."
echo ""

SPRINT_ENABLED=false
SPRINT_WEEKS=2

if ask_yes_no "Enable sprint management?" "y"; then
    SPRINT_ENABLED=true
    SPRINT_WEEKS=$(ask_number "Sprint duration in weeks" "2" "1" "6")
    echo "  ✓ Sprints enabled ($SPRINT_WEEKS-week cycles)"
else
    echo "  ✓ Sprints disabled"
fi

echo ""

# Step 3: Session compaction
echo "─── Step 3/3: Session Compaction ───"
echo ""
echo "Over time, daily session files accumulate. Compaction archives"
echo "older files into monthly summaries + zip, keeping recent files intact."
echo ""

COMPACT_ENABLED=false
COMPACT_RETENTION=30
COMPACT_GROUP="month"

if ask_yes_no "Enable session compaction?" "y"; then
    COMPACT_ENABLED=true
    COMPACT_RETENTION=$(ask_number "Keep recent sessions (days)" "30" "7" "365")

    if [[ "$SPRINT_ENABLED" == "true" ]]; then
        echo ""
        echo "  Group archived sessions by:"
        echo "    1) month  (e.g. 2026-07.md + .zip)"
        echo "    2) sprint (e.g. sprint-2026-07-06.md + .zip)"
        read -p "  Choice [1]: " group_choice
        group_choice="${group_choice:-1}"
        if [[ "$group_choice" == "2" ]]; then
            COMPACT_GROUP="sprint"
        fi
    fi

    echo "  ✓ Compaction enabled: retain ${COMPACT_RETENTION}d, group by ${COMPACT_GROUP}"
else
    echo "  ✓ Compaction disabled"
fi

echo ""

# --- Write config ---

CONFIG_FILE="$CTX_ROOT/.workflow-config.json"

cat > "$CONFIG_FILE" <<EOF
{
  "version": "1.0.0",
  "ai_context_root": "$CTX_ROOT",
  "sprint": {
    "enabled": $SPRINT_ENABLED,
    "duration_weeks": $SPRINT_WEEKS
  },
  "compaction": {
    "enabled": $COMPACT_ENABLED,
    "retention_days": $COMPACT_RETENTION,
    "group_by": "$COMPACT_GROUP"
  }
}
EOF

echo "✓ Configuration saved: $CONFIG_FILE"

# --- Update SKILL.md path ---

update_skill_path "$CTX_ROOT"
echo "✓ SKILL.md updated with AI_CONTEXT_ROOT: $CTX_ROOT"

# --- Ensure directory structure ---

mkdir -p "$CTX_ROOT/sessions/archive"
mkdir -p "$CTX_ROOT/sprints"
mkdir -p "$CTX_ROOT/tasks/todo"
mkdir -p "$CTX_ROOT/tasks/done"
mkdir -p "$CTX_ROOT/focus"
mkdir -p "$CTX_ROOT/roadmap"
mkdir -p "$CTX_ROOT/meetings"

echo "✓ Directory structure ensured"
echo ""
echo "════════════════════════════════════════════"
echo "  Setup complete! Configuration summary:"
echo ""
echo "  Root:       $CTX_ROOT"
echo "  Sprints:    $( [[ $SPRINT_ENABLED == true ]] && echo "enabled (${SPRINT_WEEKS}w)" || echo "disabled" )"
echo "  Compaction: $( [[ $COMPACT_ENABLED == true ]] && echo "enabled (retain ${COMPACT_RETENTION}d, by ${COMPACT_GROUP})" || echo "disabled" )"
echo "════════════════════════════════════════════"
