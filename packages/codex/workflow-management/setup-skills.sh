#!/usr/bin/env bash
# setup-skills.sh — Interactive wizard for skill-workflow-management configuration
#
# Usage:
#   ./setup-skills.sh                      # Interactive wizard
#   ./setup-skills.sh --path /abs/path [--record-language English] [--force]
#   ./setup-skills.sh --path /abs/path --here   # per-project context
#
# The wizard configures:
#   1. AI_CONTEXT_ROOT path
#   2. Sprint mode (enabled/disabled, duration)
#   3. Session compaction (retention days, grouping)
#   4. Language for human-authored context records
#
# The runtime configuration is saved to: <AI_CONTEXT_ROOT>/.workflow-config.json
# A small user-local pointer is kept only so the compaction command can be run
# without repeating the context path.
#
# --here scaffolds a per-project context that is attached to a multi-root
# workspace (a root holding .workflow-config.json) rather than through the
# user-local pointer. With --here the pointer is neither read nor written, so
# several projects on one machine can each keep an independent context. Setup
# then prints the snippet to add to the .code-workspace file.

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management"
CONTEXT_POINTER_FILE="$CONFIG_DIR/context-path.json"

if ! command -v python3 >/dev/null 2>&1; then
    echo "ERROR: Required command not found: python3" >&2
    exit 1
fi

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

print_workspace_snippet() {
    local root="$1"
    cat <<EOF

── Attach this context to your VS Code workspace ─────────────
Add the context directory as a root in your .code-workspace file:

  {
    "folders": [
      { "path": "your-project" },
      { "path": "$root" }
    ]
  }

A relative "path" also works when the .code-workspace file sits beside the
directory. Then reload the window (or use File > Add Folder to Workspace...).
The agent resolves this context from the workspace root that contains
.workflow-config.json; no user-local pointer is used.
─────────────────────────────────────────────────────────────
EOF
}

ensure_layout() {
    local root="$1"
    mkdir -p "$root/sessions/archive"
    mkdir -p "$root/sprints"
    mkdir -p "$root/tasks/todo"
    mkdir -p "$root/tasks/done"
    mkdir -p "$root/focus"
    mkdir -p "$root/roadmap"
    mkdir -p "$root/meetings"
}

usage() {
    cat <<'EOF'
Usage:
  ./setup-skills.sh
  ./setup-skills.sh [--force]
  ./setup-skills.sh --path /absolute/path [--record-language Language] [--force] [--here]

By default, setup refuses to replace an existing context configuration or a
pointer to a different context. Use --force only when reconfiguration is
intentional.

--here scaffolds a per-project context without touching the user-local
pointer, for a context attached to a multi-root workspace. Setup prints the
.code-workspace snippet to add.
EOF
}

read_pointer_root() {
    python3 - "$CONTEXT_POINTER_FILE" <<'PY' 2>/dev/null || true
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    value = json.load(handle).get("ai_context_root", "")
print(value if isinstance(value, str) else "")
PY
}

ensure_config_write_allowed() {
    local root="$1"
    local config_file="$root/.workflow-config.json"
    local existing_root=""

    if [[ -f "$config_file" && "$FORCE" != "true" ]]; then
        echo "ERROR: Configuration already exists: $config_file. Use --force to replace it." >&2
        return 1
    fi

    # --here does not touch the user-local pointer, so its state is irrelevant.
    if [[ "$HERE" == "true" ]]; then
        return 0
    fi

    if [[ -f "$CONTEXT_POINTER_FILE" ]]; then
        existing_root=$(read_pointer_root)
        if [[ -z "$existing_root" && "$FORCE" != "true" ]]; then
            echo "ERROR: Context pointer is invalid: $CONTEXT_POINTER_FILE. Use --force to replace it." >&2
            return 1
        fi
        if [[ -n "$existing_root" && "$existing_root" != "$root" && "$FORCE" != "true" ]]; then
            echo "ERROR: Context pointer already targets $existing_root. Use --force to replace it." >&2
            return 1
        fi
    fi
}

FORCE=false
HERE=false
NEW_PATH=""
RECORD_LANGUAGE_ARG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --path)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: --path requires an absolute path." >&2
                exit 1
            fi
            if [[ "$2" == --* ]]; then
                echo "ERROR: --path requires an absolute path." >&2
                exit 1
            fi
            NEW_PATH="$2"
            shift 2
            ;;
        --record-language)
            if [[ $# -lt 2 ]]; then
                echo "ERROR: --record-language requires a value." >&2
                exit 1
            fi
            if [[ "$2" == --* ]]; then
                echo "ERROR: --record-language requires a value." >&2
                exit 1
            fi
            RECORD_LANGUAGE_ARG="$2"
            shift 2
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --here)
            HERE=true
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "ERROR: Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# --- Non-interactive mode ---

if [[ -n "$NEW_PATH" ]]; then
    RECORD_LANGUAGE="${RECORD_LANGUAGE_ARG:-English}"
    if [[ "$NEW_PATH" != /* ]]; then
        echo "ERROR: Path must be absolute (start with /). Got: $NEW_PATH"
        exit 1
    fi
    ensure_config_write_allowed "$NEW_PATH"
    if [[ "$HERE" == "true" ]]; then
        mkdir -p "$NEW_PATH"
    else
        mkdir -p "$NEW_PATH" "$CONFIG_DIR"
    fi
    python3 - "$NEW_PATH/.workflow-config.json" "$NEW_PATH" "$RECORD_LANGUAGE" <<'PY'
import json
import sys
payload = {
    "version": "1.2.0",
    "ai_context_root": sys.argv[2],
    "record_language": sys.argv[3],
    "sprint": {"enabled": True, "duration_weeks": 2},
    "compaction": {"enabled": True, "retention_days": 30, "group_by": "month"},
}
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")
PY
    if [[ "$HERE" != "true" ]]; then
        python3 - "$CONTEXT_POINTER_FILE" "$NEW_PATH" <<'PY'
import json
import sys
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump({"ai_context_root": sys.argv[2]}, handle, indent=2)
    handle.write("\n")
PY
    fi
    echo "✓ Configuration saved: $NEW_PATH/.workflow-config.json"
    ensure_layout "$NEW_PATH"
    echo "✓ Directory structure ensured"
    if [[ "$HERE" == "true" ]]; then
        print_workspace_snippet "$NEW_PATH"
    fi
    exit 0
fi

if [[ -n "$RECORD_LANGUAGE_ARG" ]]; then
    echo "ERROR: --record-language requires --path in non-interactive mode." >&2
    exit 1
fi

# --- Interactive wizard ---

echo "╔══════════════════════════════════════════════════════════╗"
echo "║   skill-workflow-management — Configuration Wizard      ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Step 1: AI_CONTEXT_ROOT
echo "─── Step 1/4: AI Context Root ───"
echo ""
echo "Where should session files, tasks, and sprint data be stored?"
echo "This must be an absolute path to an existing (or new) directory."
echo ""

current_path=""
if [[ -f "$CONTEXT_POINTER_FILE" ]]; then
    current_path=$(python3 - "$CONTEXT_POINTER_FILE" <<'PY' 2>/dev/null || true
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    print(json.load(handle).get("ai_context_root", ""))
PY
)
fi
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

ensure_config_write_allowed "$CTX_ROOT"

echo ""

# Step 2: Sprint configuration
echo "─── Step 2/4: Sprint Management ───"
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
echo "─── Step 3/4: Session Compaction ───"
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

# Step 4: Record language
echo "─── Step 4/4: Record Language ───"
echo ""
echo "Choose the language used for sessions, tasks, focus notes, meetings,"
echo "roadmaps, and RECAP entries. Code, README files, and commit messages remain English."
read -p "Record language [English]: " RECORD_LANGUAGE
RECORD_LANGUAGE="${RECORD_LANGUAGE:-English}"

echo ""

# --- Write config ---

if [[ "$HERE" != "true" ]]; then
    mkdir -p "$CONFIG_DIR"
fi

python3 - "$CTX_ROOT/.workflow-config.json" "$CTX_ROOT" "$SPRINT_ENABLED" "$SPRINT_WEEKS" "$COMPACT_ENABLED" "$COMPACT_RETENTION" "$COMPACT_GROUP" "$RECORD_LANGUAGE" <<'PY'
import json
import sys

path, root, sprint_enabled, sprint_weeks, compact_enabled, retention, group, record_language = sys.argv[1:]
payload = {
    "version": "1.2.0",
    "ai_context_root": root,
    "record_language": record_language,
    "sprint": {"enabled": sprint_enabled == "true", "duration_weeks": int(sprint_weeks)},
    "compaction": {"enabled": compact_enabled == "true", "retention_days": int(retention), "group_by": group},
}
with open(path, "w", encoding="utf-8") as handle:
    json.dump(payload, handle, indent=2)
    handle.write("\n")
PY

if [[ "$HERE" != "true" ]]; then
    python3 - "$CONTEXT_POINTER_FILE" "$CTX_ROOT" <<'PY'
import json
import sys
with open(sys.argv[1], "w", encoding="utf-8") as handle:
    json.dump({"ai_context_root": sys.argv[2]}, handle, indent=2)
    handle.write("\n")
PY
fi

echo "✓ Configuration saved: $CTX_ROOT/.workflow-config.json"

# --- Ensure directory structure ---

ensure_layout "$CTX_ROOT"

echo "✓ Directory structure ensured"
echo ""
echo "════════════════════════════════════════════"
echo "  Setup complete! Configuration summary:"
echo ""
echo "  Root:       $CTX_ROOT"
echo "  Records:    $RECORD_LANGUAGE"
echo "  Sprints:    $( [[ $SPRINT_ENABLED == true ]] && echo "enabled (${SPRINT_WEEKS}w)" || echo "disabled" )"
echo "  Compaction: $( [[ $COMPACT_ENABLED == true ]] && echo "enabled (retain ${COMPACT_RETENTION}d, by ${COMPACT_GROUP})" || echo "disabled" )"
echo "  Pointer:    $( [[ $HERE == true ]] && echo "not written (--here: attach via .code-workspace)" || echo "$CONTEXT_POINTER_FILE" )"
echo "════════════════════════════════════════════"

if [[ "$HERE" == "true" ]]; then
    print_workspace_snippet "$CTX_ROOT"
fi
