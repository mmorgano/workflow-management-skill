#!/usr/bin/env bash
# sync-codex-package.sh — Propagate shared files from the repository root
# (the Claude Code skill) into packages/codex/workflow-management/ (the
# installable Codex package).
#
# The two skills share the workflow contract, the setup and compaction
# scripts, the reference files, and the starter example. Only the activation
# file (SKILL.md) and the Codex agent manifest (agents/openai.yaml) are
# adapter-specific and are never touched here.
#
# Usage:
#   ./sync-codex-package.sh            # copy root -> package
#   ./sync-codex-package.sh --check    # report drift, change nothing, exit 1 if any
#
# CI already enforces that the copies match (tests/smoke-test.sh); this script
# is the convenient way to keep them matching while editing the shared files.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
PACKAGE="$ROOT/packages/codex/workflow-management"

# Shared files, relative to the repository root. Keep this list in sync with
# the cmp loop in tests/smoke-test.sh.
SHARED_FILES=(
    CORE.md
    conventions.md
    setup-skills.sh
    setup-skills.ps1
    compact-sessions.sh
    references/sessions.md
    references/tasks.md
    references/planning-and-notes.md
    references/steering.md
    references/tracking.md
    references/bootstrap.md
    references/compaction.md
    examples/basic-ai-context/README.md
    examples/basic-ai-context/RECAP.md
    examples/basic-ai-context/tasks/INDEX.md
)

CHECK_ONLY=false
case "${1:-}" in
    --check) CHECK_ONLY=true ;;
    "") ;;
    -h|--help)
        sed -n '2,20p' "$0"
        exit 0
        ;;
    *)
        echo "ERROR: unknown argument: $1" >&2
        exit 1
        ;;
esac

if [[ ! -d "$PACKAGE" ]]; then
    echo "ERROR: Codex package directory not found: $PACKAGE" >&2
    exit 1
fi

drift=0
copied=0

for rel in "${SHARED_FILES[@]}"; do
    src="$ROOT/$rel"
    dest="$PACKAGE/$rel"
    if [[ ! -f "$src" ]]; then
        echo "ERROR: shared file missing from root: $rel" >&2
        exit 1
    fi
    if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
        continue
    fi
    if [[ "$CHECK_ONLY" == "true" ]]; then
        echo "DRIFT: packages/codex/workflow-management/$rel differs from root"
        drift=1
    else
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        echo "synced: $rel"
        copied=$((copied + 1))
    fi
done

if [[ "$CHECK_ONLY" == "true" ]]; then
    if [[ "$drift" -eq 1 ]]; then
        echo "Codex package is out of sync. Run ./sync-codex-package.sh" >&2
        exit 1
    fi
    echo "Codex package is in sync."
    exit 0
fi

if [[ "$copied" -eq 0 ]]; then
    echo "Codex package already in sync; nothing to do."
else
    echo "Synced $copied file(s) into packages/codex/workflow-management/."
fi
