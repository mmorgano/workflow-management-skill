#!/usr/bin/env bash
# compact-sessions.sh — Archive old session files into monthly/sprint summaries + zip
#
# Usage:
#   ./compact-sessions.sh                    # Uses config from AI_CONTEXT_ROOT
#   ./compact-sessions.sh /path/to/ai-context
#   ./compact-sessions.sh --dry-run          # Show what would be done
#   ./compact-sessions.sh --delete-originals # Delete only after ZIP verification
#
# Reads configuration from <AI_CONTEXT_ROOT>/.workflow-config.json
# Keeps the most recent N days of sessions intact (default: 30)
# Groups older sessions by month (or sprint) into:
#   sessions/archive/YYYY-MM.md       (one-liner summaries)
#   sessions/archive/YYYY-MM.zip      (original files)

set -euo pipefail

CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/skill-workflow-management"
GLOBAL_CONFIG_FILE="$CONFIG_DIR/config.json"

DRY_RUN=false
DELETE_ORIGINALS=false

# --- Parse args ---

CTX_ROOT=""
for arg in "$@"; do
    case "$arg" in
        --dry-run) DRY_RUN=true ;;
        --delete-originals) DELETE_ORIGINALS=true ;;
        /*) CTX_ROOT="$arg" ;;
        *) echo "Unknown argument: $arg"; exit 1 ;;
    esac
done

# Resolve AI_CONTEXT_ROOT from the explicit argument or global configuration.
if [[ -z "$CTX_ROOT" ]]; then
    if [[ -f "$GLOBAL_CONFIG_FILE" ]]; then
        CTX_ROOT=$(python3 -c "import json; print(json.load(open('$GLOBAL_CONFIG_FILE')).get('ai_context_root', ''))" 2>/dev/null || true)
    fi
fi

if [[ -z "$CTX_ROOT" || ! -d "$CTX_ROOT" ]]; then
    echo "ERROR: Cannot resolve AI_CONTEXT_ROOT. Pass it as argument or run setup-skills.sh first."
    exit 1
fi

CONFIG_FILE="$GLOBAL_CONFIG_FILE"
if [[ -f "$CTX_ROOT/.workflow-config.json" ]]; then
    CONFIG_FILE="$CTX_ROOT/.workflow-config.json"
fi
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
echo "  Delete originals:     $DELETE_ORIGINALS"
echo ""

# Collect session files older than cutoff
declare -A MONTH_FILES  # group key -> newline-separated file list
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
            # Sprint grouping: use the explicit, locale-independent Sprint ID.
            sprint_id=$(sed -n 's/^- \*\*Sprint ID\*\*: \([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\)$/\1/p' "$f" | head -1 || echo "")
            if [[ -n "$sprint_id" ]]; then
                key="sprint-$sprint_id"
            else
                key="${file_date:0:7}"
            fi
        fi

        MONTH_FILES["$key"]+="$f"$'\n'
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
    mapfile -t files < <(printf '%s' "${MONTH_FILES[$key]}" | sort)
    recap_file="$ARCHIVE_DIR/${key}.md"
    zip_file="$ARCHIVE_DIR/${key}.zip"

    echo "── Group: $key (${#files[@]} files)"

    if [[ "$DRY_RUN" == "true" ]]; then
        for f in "${files[@]}"; do
            echo "    → $(basename "$f")"
        done
        echo "    Would create: $recap_file"
        echo "    Would create: $zip_file"
        if [[ "$DELETE_ORIGINALS" == "true" ]]; then
            echo "    Would delete original files after verification"
        else
            echo "    Would move original files to: $ARCHIVE_DIR/originals/$key"
        fi
        echo ""
        continue
    fi

    # Build recap summary
    {
        echo "# Session Archive — $key"
        echo ""
        echo "| Date | Summary |"
        echo "|------|---------|"

        for f in "${files[@]}"; do
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
    (cd "$SESSIONS_DIR" && zip -q "$zip_file" -- "${files[@]##*/}")

    # Verify the archive before touching original files.
    if ! unzip -tqq "$zip_file"; then
        echo "ERROR: Archive verification failed; originals were left untouched."
        rm -f "$zip_file"
        exit 1
    fi

    if [[ "$DELETE_ORIGINALS" == "true" ]]; then
        rm -- "${files[@]}"
        echo "    ✓ Deleted ${#files[@]} original file(s) after verification"
    else
        recovery_dir="$ARCHIVE_DIR/originals/$key"
        mkdir -p "$recovery_dir"
        mv -- "${files[@]}" "$recovery_dir/"
        echo "    ✓ Moved ${#files[@]} original file(s) to: $recovery_dir"
    fi

    echo "    ✓ Created: $(basename "$recap_file")"
    echo "    ✓ Created: $(basename "$zip_file")"
    echo ""
done

echo "════════════════════════════════════════════"
echo "  Compaction complete!"
echo "  Archive: $ARCHIVE_DIR"
echo "════════════════════════════════════════════"
