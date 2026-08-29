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
CONTEXT_POINTER_FILE="$CONFIG_DIR/context-path.json"

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
    if [[ -f "$CONTEXT_POINTER_FILE" ]]; then
        CTX_ROOT=$(python3 - "$CONTEXT_POINTER_FILE" <<'PY' 2>/dev/null || true
import json
import sys
with open(sys.argv[1], encoding="utf-8") as handle:
    print(json.load(handle).get("ai_context_root", ""))
PY
)
    fi
fi

if [[ -z "$CTX_ROOT" || ! -d "$CTX_ROOT" ]]; then
    echo "ERROR: Cannot resolve AI_CONTEXT_ROOT. Pass it as argument or run setup-skills.sh first."
    exit 1
fi

require_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "ERROR: Required command not found: $1" >&2
        exit 1
    fi
}

require_command python3
require_command zip
require_command unzip

CONFIG_FILE="$CTX_ROOT/.workflow-config.json"
SESSIONS_DIR="$CTX_ROOT/sessions"
ARCHIVE_DIR="$SESSIONS_DIR/archive"

# --- Read config ---

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "ERROR: Configuration not found: $CONFIG_FILE. Run setup-skills.sh first."
    exit 1
fi

read_config() {
    python3 - "$CONFIG_FILE" <<'PY'
import json
import sys

with open(sys.argv[1], encoding="utf-8") as handle:
    config = json.load(handle)

compact = config.get("compaction", {})
sprint = config.get("sprint", {})
retention = compact.get("retention_days", 30)
weeks = sprint.get("duration_weeks", 2)
if type(retention) is not int or not 7 <= retention <= 365:
    raise ValueError("compaction.retention_days must be an integer between 7 and 365")
if type(weeks) is not int or not 1 <= weeks <= 6:
    raise ValueError("sprint.duration_weeks must be an integer between 1 and 6")
if compact.get("group_by", "month") not in ("month", "sprint"):
    raise ValueError("compaction.group_by must be 'month' or 'sprint'")
if type(compact.get("enabled", False)) is not bool or type(sprint.get("enabled", False)) is not bool:
    raise ValueError("enabled values must be booleans")
print(str(compact.get("enabled", False)).lower())
print(retention)
print(compact.get("group_by", "month"))
print(str(sprint.get("enabled", False)).lower())
print(weeks)
PY
}

if ! config_output=$(read_config); then
    echo "ERROR: Invalid configuration in $CONFIG_FILE."
    exit 1
fi
mapfile -t config_values <<< "$config_output"
COMPACT_ENABLED="${config_values[0]}"
RETENTION_DAYS="${config_values[1]}"
GROUP_BY="${config_values[2]}"
SPRINT_ENABLED="${config_values[3]}"
SPRINT_WEEKS="${config_values[4]}"

if [[ "$COMPACT_ENABLED" != "true" ]]; then
    echo "Compaction is disabled in configuration. Nothing to do."
    echo "Run setup-skills.sh to enable it."
    exit 0
fi

# --- Read sprint config for buffer calculation ---

# --- Calculate effective retention (safety buffer) ---
# With sprints: protect at least current + previous sprint (2 × duration)
# Without sprints: minimum 25 days floor
# Final cutoff = max(retention_days, buffer)

MIN_FLOOR=25  # absolute minimum regardless of config

if [[ "$SPRINT_ENABLED" == "true" ]]; then
    SPRINT_BUFFER=$(( SPRINT_WEEKS * 2 * 7 ))
    EFFECTIVE_RETENTION=$(( RETENTION_DAYS > SPRINT_BUFFER ? (RETENTION_DAYS > MIN_FLOOR ? RETENTION_DAYS : MIN_FLOOR) : (SPRINT_BUFFER > MIN_FLOOR ? SPRINT_BUFFER : MIN_FLOOR) ))
else
    EFFECTIVE_RETENTION=$(( RETENTION_DAYS > MIN_FLOOR ? RETENTION_DAYS : MIN_FLOOR ))
fi

# --- Identify files to archive ---

mkdir -p "$ARCHIVE_DIR"

CUTOFF_DATE=$(python3 - "$EFFECTIVE_RETENTION" <<'PY'
from datetime import datetime, timedelta
import sys
print((datetime.now() - timedelta(days=int(sys.argv[1]))).strftime('%Y-%m-%d'))
PY
)
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
    if ! python3 - "$file_date" <<'PY' >/dev/null 2>&1
from datetime import date
import sys
date.fromisoformat(sys.argv[1])
PY
    then
        echo "WARNING: Skipping session with invalid date: $basename" >&2
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
            sprint_id=$(awk -F ': ' '/^- \*\*Sprint ID\*\*:/ { print $2; exit }' "$f" 2>/dev/null || true)
            if [[ "$sprint_id" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
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

    # Build new archive files in the archive directory and replace the public
    # files only after the ZIP passes verification. This prevents a failed ZIP
    # command from leaving a recap that claims files were archived.
    tmp_recap=$(mktemp "$ARCHIVE_DIR/.${key}.md.XXXXXX")
    tmp_zip=$(mktemp "$ARCHIVE_DIR/.${key}.zip.XXXXXX")
    rm -f "$tmp_zip"

    # Preserve rows from an existing recap because a month can be compacted
    # more than once.
    {
        echo "# Session Archive — $key"
        echo ""
        echo "| Date | Summary |"
        echo "|------|---------|"

        if [[ -f "$recap_file" ]]; then
            awk '/^\| [0-9][0-9][0-9][0-9]-/ { print }' "$recap_file"
        fi

        for f in "${files[@]}"; do
            basename=$(basename "$f")
            file_date="${basename#SESSION_}"
            file_date="${file_date%.md}"

            # Accept the Italian and English session templates.
            summary=$(awk '/^## (Lavoro svolto|Work done)$/{found=1; next} found && /^- .+/{gsub(/^- /,""); print; exit}' "$f" 2>/dev/null || true)
            summary="${summary:-—}"
            summary="${summary//|/\\|}"
            # Truncate to 80 chars
            if [[ ${#summary} -gt 80 ]]; then
                summary="${summary:0:77}..."
            fi
            echo "| $file_date | $summary |"
        done

        echo ""
        echo "---"
        echo "Original files archived in: $(basename "$zip_file")"
    } > "$tmp_recap"

    # Start from the existing ZIP, if any, so incremental compaction keeps
    # earlier source files as well.
    if [[ -f "$zip_file" ]]; then
        cp "$zip_file" "$tmp_zip"
    fi

    (cd "$SESSIONS_DIR" && zip -q "$tmp_zip" -- "${files[@]##*/}")

    # Verify the archive before touching original files.
    if ! unzip -tqq "$tmp_zip"; then
        echo "ERROR: Archive verification failed; originals were left untouched."
        rm -f "$tmp_recap" "$tmp_zip"
        exit 1
    fi

    mv -f "$tmp_zip" "$zip_file"
    mv -f "$tmp_recap" "$recap_file"

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
