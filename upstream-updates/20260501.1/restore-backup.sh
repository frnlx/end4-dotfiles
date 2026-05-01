#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# restore-backup.sh - Rollback utility for upstream update 20260501.1
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

usage() {
    cat <<EOF
Usage: $0 [TIMESTAMP]

Restore backups created by apply-changes.sh

Arguments:
    TIMESTAMP   The backup timestamp to restore (e.g., 1742569200)
                If not provided, lists available backups.

Options:
    -h, --help  Show this help message

Examples:
    $0                  # List available backups
    $0 1742569200       # Restore backups from timestamp 1742569200
EOF
}

# Directories to search for backups
search_dirs=(
    "$HOME/.config/hypr"
    "$HOME/.config/quickshell"
    "$HOME/.config/kitty"
    "$HOME/.config/matugen"
    "$HOME/.config/fish"
)

list_backups() {
    log_info "Searching for backups..."
    echo ""
    
    local found_any=0
    declare -A timestamps
    
    for dir in "${search_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            while IFS= read -r -d '' bak; do
                # Extract timestamp from filename.bak.TIMESTAMP
                ts="${bak##*.bak.}"
                if [[ "$ts" =~ ^[0-9]+$ ]]; then
                    timestamps[$ts]=1
                    found_any=1
                fi
            done < <(find "$dir" -name "*.bak.[0-9]*" -print0 2>/dev/null)
        fi
    done
    
    if [[ $found_any -eq 0 ]]; then
        log_warn "No backups found."
        return 1
    fi
    
    echo "Available backup timestamps:"
    echo ""
    for ts in $(echo "${!timestamps[@]}" | tr ' ' '\n' | sort -rn); do
        local date_str
        date_str=$(date -d "@$ts" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown date")
        echo "  $ts  ($date_str)"
    done
    echo ""
    echo "To restore, run: $0 <TIMESTAMP>"
    return 0
}

restore_backup() {
    local timestamp="$1"
    local restored=0
    local failed=0
    
    log_info "Restoring backups with timestamp: $timestamp"
    echo ""
    
    for dir in "${search_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            continue
        fi
        
        while IFS= read -r -d '' bak; do
            # Get original path by removing .bak.TIMESTAMP suffix
            original="${bak%.bak.$timestamp}"
            
            if [[ "$original" == "$bak" ]]; then
                continue  # Doesn't match our timestamp
            fi
            
            # Remove current file if it exists
            if [[ -e "$original" || -L "$original" ]]; then
                rm -rf "$original"
            fi
            
            # Restore backup
            if mv "$bak" "$original"; then
                log_success "Restored: $original"
                ((restored++))
            else
                log_error "Failed to restore: $original"
                ((failed++))
            fi
        done < <(find "$dir" -name "*.bak.$timestamp" -print0 2>/dev/null)
    done
    
    echo ""
    echo "=============================================="
    echo "  RESTORE SUMMARY"
    echo "=============================================="
    echo "  Restored: $restored files"
    echo "  Failed: $failed files"
    echo "=============================================="
    
    if [[ $restored -eq 0 ]]; then
        log_warn "No backups found for timestamp: $timestamp"
        return 1
    fi
    
    log_success "Restore complete. You may need to restart Quickshell."
    return 0
}

# Main
case "${1:-}" in
    -h|--help)
        usage
        exit 0
        ;;
    "")
        list_backups
        exit $?
        ;;
    *)
        if [[ ! "$1" =~ ^[0-9]+$ ]]; then
            log_error "Invalid timestamp: $1"
            echo "Timestamp should be a Unix epoch number (e.g., 1742569200)"
            exit 1
        fi
        restore_backup "$1"
        exit $?
        ;;
esac
