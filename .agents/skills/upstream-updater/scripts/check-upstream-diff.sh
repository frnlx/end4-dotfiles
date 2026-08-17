#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# check-upstream-diff.sh - Compare upstream dots-hyprland with end4-dotfiles
# ============================================================================

UPSTREAM_DIR="${1:-/home/frnlx/end4files/dots-hyprland}"
FORK_DIR="${2:-/home/frnlx/end4files/end4-dotfiles}"

if [[ ! -d "$UPSTREAM_DIR/.git" ]]; then
    echo "[ERROR] Upstream directory not found at: $UPSTREAM_DIR" >&2
    exit 1
fi

if [[ ! -d "$FORK_DIR/.git" ]]; then
    echo "[ERROR] Fork directory not found at: $FORK_DIR" >&2
    exit 1
fi

echo "=============================================="
echo "  UPSTREAM SYNC INSPECTOR"
echo "=============================================="
echo "  Upstream: $UPSTREAM_DIR"
echo "  Fork:     $FORK_DIR"
echo "=============================================="
echo ""

# Find latest bundle in fork
LATEST_BUNDLE=$(find "$FORK_DIR/upstream-updates" -maxdepth 1 -mindepth 1 -type d | sort -V | tail -n 1)
if [[ -n "$LATEST_BUNDLE" && -f "$LATEST_BUNDLE/changes.md" ]]; then
    echo "[INFO] Latest bundle found: $(basename "$LATEST_BUNDLE")"
    LAST_COMMIT=$(grep -E '^\*\*Commit range:\*\*' "$LATEST_BUNDLE/changes.md" | sed -E 's/.*→ `?([a-f0-9]+)`?.*/\1/' || true)
    if [[ -n "$LAST_COMMIT" ]]; then
        echo "[INFO] Last synced commit hash: $LAST_COMMIT"
    fi
else
    LAST_COMMIT=""
fi

# Fetch upstream status
echo "[INFO] Checking upstream git status..."
git -C "$UPSTREAM_DIR" fetch origin main --quiet 2>/dev/null || true

UPSTREAM_HEAD=$(git -C "$UPSTREAM_DIR" rev-parse HEAD)
ORIGIN_MAIN=$(git -C "$UPSTREAM_DIR" rev-parse origin/main)

echo "  Upstream HEAD:        $UPSTREAM_HEAD"
echo "  Upstream origin/main: $ORIGIN_MAIN"
echo ""

BASE_COMMIT="${LAST_COMMIT:-$UPSTREAM_HEAD}"
COMMIT_COUNT=$(git -C "$UPSTREAM_DIR" rev-list --count "$BASE_COMMIT..origin/main" 2>/dev/null || echo "0")

echo "[INFO] Commits pending sync ($BASE_COMMIT -> origin/main): $COMMIT_COUNT"
echo ""

if [[ "$COMMIT_COUNT" -gt 0 ]]; then
    echo "--- Commits List ---"
    git -C "$UPSTREAM_DIR" log --reverse --format="- **%h** (%ad): %s" --date=short "$BASE_COMMIT..origin/main"
    echo ""
    
    echo "--- Changed Files in Upstream ---"
    git -C "$UPSTREAM_DIR" diff --name-status "$BASE_COMMIT" origin/main
    echo ""
    
    echo "--- Fork Exclusions Check ---"
    EXCLUSIONS=(
        "Booru"
        "AiChat"
        "Translator.qml"
        "translator"
        "aiChat"
        "anime"
        "random_konachan_wall.sh"
        "waifu"
    )
    
    DIFF_FILES=$(git -C "$UPSTREAM_DIR" diff --name-only "$BASE_COMMIT" origin/main)
    found_exclusions=0
    for exc in "${EXCLUSIONS[@]}"; do
        matches=$(echo "$DIFF_FILES" | grep -E "$exc" || true)
        if [[ -n "$matches" ]]; then
            echo "[WARNING] Excluded pattern '$exc' matched in upstream changes:"
            echo "$matches" | sed 's/^/  - /'
            found_exclusions=1
        fi
    done
    
    if [[ $found_exclusions -eq 0 ]]; then
        echo "[OK] No excluded components touched in this upstream range."
    else
        echo "[IMPORTANT] Ensure the above files are excluded from sync & apply-changes.sh!"
    fi
fi

echo ""
echo "=============================================="
