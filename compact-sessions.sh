#!/usr/bin/env bash
# compact-sessions.sh — Archive old session files into monthly/sprint summaries + zip
#
# Usage:
#   ./compact-sessions.sh                    # Uses config from AI_CONTEXT_ROOT
#   ./compact-sessions.sh /path/to/ai-context
#   ./compact-sessions.sh --dry-run          # Show what would be done
#
# Reads configuration from <AI_CONTEXT_ROOT>/.workflow-config.json
# Keeps the most recent N days of sessions intact (default: 30)
# Groups older sessions by month (or sprint) into:
#   sessions/archive/YYYY-MM.md       (one-liner summaries)
#   sessions/archive/YYYY-MM.zip      (original files)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/SKILL.md"

DRY_RUN=false

# --- Parse args ---

CTX_ROOT=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        /*) CTX_ROOT="$arg" ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# Resolve AI_CONTEXT_ROOT
if [[ -z "$CTX_ROOT" ]]; then
    CTX_ROOT=$(sed -n 's/^> \*\*AI_CONTEXT_ROOT\*\*: `\(.*\)`$/\1/p' "$SKILL_FILE" 2>/dev/null | head -1)
fi

if [[ -z "$CTX_ROOT" || ! -d "$CTX_ROOT" ]]; then
    echo "ERROR: Cannot resolve AI_CONTEXT_ROOT. Pass it as argument or run setup-skills.sh first."
    exit 1
fi

CONFIG_FILE="$CTX_ROOT/.workflow-config.json"
SESSIONS_DIR="$CTX_ROOT/sessions"
ARCHIVE_DIR="$SESSIONS_DIR/archive"

# --- Read config ---

if [[ -f "$CONFIG_FILE" ]]; then
    COMPACT_ENABLED=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(str(c.get('compaction',{}).get('enabled', False)).lower())" 2>/dev/null || echo "false")
    RETENTION_DAYS=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(c.get('compaction',{}).get('retention_days', 30))" 2>/dev/null || echo "30")
    GROUP_BY=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(c.get('compaction',{}).get('group_by', 'month'))" 2>/dev/null || echo "month")
else
    echo "WARNING: No config file found at $CONFIG_FILE. Using defaults."
    COMPACT_ENABLED="true"
    RETENTION_DAYS=30
    GROUP_BY="month"
fi

if [[ "$COMPACT_ENABLED" != "true" ]]; then
    echo "Compaction is disabled in configuration. Nothing to do."
    echo "Run setup-skills.sh to enable it."
    exit 0
fi

# --- Read sprint config for buffer calculation ---

SPRINT_ENABLED=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(str(c.get('sprint',{}).get('enabled', False)).lower())" 2>/dev/null || echo "false")
SPRINT_WEEKS=$(python3 -c "import json; c=json.load(open('$CONFIG_FILE')); print(c.get('sprint',{}).get('duration_weeks', 2))" 2>/dev/null || echo "2")

# --- Calculate effective retention (safety buffer) ---
# With sprints: protect at least current + previous sprint (2 × duration)
# Without sprints: minimum 25 days floor
# Final cutoff = max(retention_days, buffer)

MIN_FLOOR=25  # absolute minimum regardless of config

if [[ "$SPRINT_ENABLED" == "true" ]]; then
    SPRINT_BUFFER=$(( SPRINT_WEEKS * 2 * 7 ))
    EFFECTIVE_RETENTION=$(python3 -c "print(max($RETENTION_DAYS, $SPRINT_BUFFER, $MIN_FLOOR))")
else
    EFFECTIVE_RETENTION=$(python3 -c "print(max($RETENTION_DAYS, $MIN_FLOOR))")
fi

# --- Identify files to archive ---

mkdir -p "$ARCHIVE_DIR"

CUTOFF_DATE=$(python3 -c "from datetime import datetime, timedelta; print((datetime.now() - timedelta(days=$EFFECTIVE_RETENTION)).strftime('%Y-%m-%d'))")
echo "Compaction settings:"
echo "  Configured retention: ${RETENTION_DAYS} days"
if [[ "$SPRINT_ENABLED" == "true" ]]; then
    echo "  Sprint buffer:        ${SPRINT_BUFFER} days (2 × ${SPRINT_WEEKS}w)"
fi
echo "  Effective retention:  ${EFFECTIVE_RETENTION} days (max of configured + buffer)"
echo "  Cutoff date:          $CUTOFF_DATE (files older than this will be archived)"
echo "  Group by:             $GROUP_BY"
echo "  Dry run:              $DRY_RUN"
echo ""

# Collect session files older than cutoff
declare -A MONTH_FILES  # month -> space-separated file list
FILES_TO_ARCHIVE=()

for f in "$SESSIONS_DIR"/SESSION_*.md; do
    [[ -f "$f" ]] || continue

    # Extract date from filename SESSION_YYYY-MM-DD.md
    basename=$(basename "$f")
    file_date="${basename#SESSION_}"
    file_date="${file_date%.md}"

    # Validate date format
    if [[ ! "$file_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        continue
    fi

    # Compare dates lexicographically (works for ISO format)
    if [[ "$file_date" < "$CUTOFF_DATE" ]]; then
        FILES_TO_ARCHIVE+=("$f")

        # Group key
        if [[ "$GROUP_BY" == "month" ]]; then
            key="${file_date:0:7}"  # YYYY-MM
        else
            # Sprint grouping: use sprint start date from file content, fallback to month
            sprint_date=$(grep -oP 'dal \K\d{2}/\d{2}/\d{4}' "$f" 2>/dev/null | head -1 || echo "")
            if [[ -n "$sprint_date" ]]; then
                # Convert DD/MM/YYYY to YYYY-MM-DD for key
                key="sprint-$(echo "$sprint_date" | awk -F/ '{print $3"-"$2"-"$1}')"
            else
                key="${file_date:0:7}"
            fi
        fi

        MONTH_FILES["$key"]="${MONTH_FILES[$key]:-} $f"
    fi
done

if [[ ${#FILES_TO_ARCHIVE[@]} -eq 0 ]]; then
    echo "No session files older than $CUTOFF_DATE found. Nothing to compact."
    exit 0
fi

echo "Found ${#FILES_TO_ARCHIVE[@]} session file(s) to archive across ${#MONTH_FILES[@]} group(s)."
echo ""

# --- Process each group ---

for key in $(echo "${!MONTH_FILES[@]}" | tr ' ' '\n' | sort); do
    files=(${MONTH_FILES[$key]})
    recap_file="$ARCHIVE_DIR/${key}.md"
    zip_file="$ARCHIVE_DIR/${key}.zip"

    echo "── Group: $key (${#files[@]} files)"

    if [[ "$DRY_RUN" == "true" ]]; then
        for f in "${files[@]}"; do
            echo "    → $(basename "$f")"
        done
        echo "    Would create: $recap_file"
        echo "    Would create: $zip_file"
        echo ""
        continue
    fi

    # Build recap summary
    {
        echo "# Session Archive — $key"
        echo ""
        echo "| Date | Summary |"
        echo "|------|---------|"

        for f in $(echo "${files[@]}" | tr ' ' '\n' | sort); do
            basename=$(basename "$f")
            file_date="${basename#SESSION_}"
            file_date="${file_date%.md}"

            # Extract first non-empty bullet from "Lavoro svolto"
            summary=$(awk '/^## Lavoro svolto/{found=1; next} found && /^- .+/{gsub(/^- /,""); print; exit}' "$f" 2>/dev/null || echo "—")
            # Truncate to 80 chars
            if [[ ${#summary} -gt 80 ]]; then
                summary="${summary:0:77}..."
            fi
            echo "| $file_date | $summary |"
        done

        echo ""
        echo "---"
        echo "Original files archived in: $(basename "$zip_file")"
    } > "$recap_file"

    # Create zip archive
    (cd "$SESSIONS_DIR" && zip -q "$zip_file" $(for f in "${files[@]}"; do basename "$f"; done))

    # Remove original files
    for f in "${files[@]}"; do
        rm "$f"
    done

    echo "    ✓ Created: $(basename "$recap_file")"
    echo "    ✓ Created: $(basename "$zip_file")"
    echo "    ✓ Removed ${#files[@]} original file(s)"
    echo ""
done

echo "════════════════════════════════════════════"
echo "  Compaction complete!"
echo "  Archive: $ARCHIVE_DIR"
echo "════════════════════════════════════════════"
