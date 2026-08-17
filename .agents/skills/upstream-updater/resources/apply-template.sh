#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# apply-changes.sh - Upstream Update Applicator for {{BUNDLE_ID}}
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKUP_TS="$(date +%s)"

# Defaults
DRY_RUN=0
RESTART=0
SKIP_PACMAN=0
SKIP_DEPS=0
AUTO_YES=0

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Apply upstream changes for bundle {{BUNDLE_ID}}.

Options:
    -n, --dry-run       Show what will be done without making changes
    -r, --restart       Restart Quickshell after applying changes
    -y, --yes           Auto-confirm all prompts (non-interactive)
    --skip-pacman       Skip the pacman update prompt
    --skip-deps         Skip the ./setup install-deps prompt
    -h, --help          Show this help message
EOF
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_dry() { echo -e "${YELLOW}[DRY-RUN]${NC} $1"; }

while [[ ${#} -gt 0 ]]; do
    case "$1" in
        -n|--dry-run) DRY_RUN=1; shift ;;
        -r|--restart) RESTART=1; shift ;;
        -y|--yes) AUTO_YES=1; shift ;;
        --skip-pacman) SKIP_PACMAN=1; shift ;;
        --skip-deps) SKIP_DEPS=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) log_error "Unknown argument: $1"; usage; exit 2 ;;
    esac
done

prompt_pacman_update() {
    if [[ $SKIP_PACMAN -eq 1 ]]; then
        log_info "Skipping pacman update (--skip-pacman)"
        return
    fi

    echo ""
    echo "=============================================="
    echo "  SYSTEM PACKAGE UPDATE"
    echo "=============================================="
    echo ""

    if [[ $DRY_RUN -eq 1 ]]; then
        log_dry "Would prompt: Run 'sudo pacman -Syu' now?"
        return
    fi

    if [[ $AUTO_YES -eq 1 ]]; then
        log_info "Auto-yes mode: Running pacman -Syu"
        sudo pacman -Syu
        return
    fi

    echo "Options:"
    echo "  [1] Run 'sudo pacman -Syu' now (recommended)"
    echo "  [2] Skip pacman update"
    echo "  [3] Abort script"
    echo ""
    
    while true; do
        read -rp "Choose an option [1/2/3]: " choice
        case "$choice" in
            1) sudo pacman -Syu; break ;;
            2) log_info "Skipping pacman update."; break ;;
            3) log_info "Aborted."; exit 0 ;;
            *) log_warn "Invalid choice." ;;
        esac
    done
}

prompt_install_deps() {
    if [[ $SKIP_DEPS -eq 1 ]]; then
        log_info "Skipping ./setup install-deps (--skip-deps)"
        return
    fi

    echo ""
    echo "=============================================="
    echo "  REBUILD DEPENDENCIES"
    echo "=============================================="
    echo ""

    if [[ $DRY_RUN -eq 1 ]]; then
        log_dry "Would prompt: Run './setup install-deps' now?"
        return
    fi

    if [[ $AUTO_YES -eq 1 ]]; then
        log_info "Auto-yes mode: Running ./setup install-deps"
        cd "$REPO_ROOT" && ./setup install-deps
        return
    fi

    echo "Options:"
    echo "  [1] Run './setup install-deps' now"
    echo "  [2] Skip rebuild"
    echo "  [3] Abort script"
    echo ""
    
    while true; do
        read -rp "Choose an option [1/2/3]: " choice
        case "$choice" in
            1) cd "$REPO_ROOT" && ./setup install-deps; break ;;
            2) log_info "Skipping dependency rebuild."; break ;;
            3) log_info "Aborted."; exit 0 ;;
            *) log_warn "Invalid choice." ;;
        esac
    done
}

if [[ $AUTO_YES -eq 0 && $DRY_RUN -eq 0 ]]; then
    echo ""
    echo "=============================================="
    echo "  UPSTREAM UPDATE: {{BUNDLE_ID}}"
    echo "=============================================="
    echo ""
    echo "Your existing configs will be backed up with suffix:"
    echo "  .bak.$BACKUP_TS"
    echo ""
    read -rp "Continue? [y/N]: " cont
    if [[ ! "$cont" =~ ^[Yy]$ ]]; then
        log_info "Aborted."
        exit 0
    fi
fi

# Files to update (repo-relative paths under dots/)
paths=(
    # {{PATHS_PLACEHOLDER}}
)

removed_paths=(
    # {{REMOVED_PATHS_PLACEHOLDER}}
)

echo ""
echo "=============================================="
echo "  UPSTREAM UPDATE: {{BUNDLE_ID}}"
echo "=============================================="
echo "  Repo root: $REPO_ROOT"
echo "=============================================="
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
    log_warn "DRY-RUN MODE - No changes will be made"
    echo ""
fi

prompt_pacman_update
prompt_install_deps

echo ""
log_info "Applying configuration changes..."
echo ""

applied=0
skipped=0
backed_up=0

for p in "${paths[@]}"; do
    src="$REPO_ROOT/$p"

    if [[ ! -e "$src" ]]; then
        log_warn "Source not found, skipping: $p"
        ((skipped++)) || true
        continue
    fi

    rel="${p#dots/}"
    dest="$HOME/$rel"
    destdir="$(dirname "$dest")"

    if [[ $DRY_RUN -eq 1 ]]; then
        if [[ -d "$src" ]]; then
            log_dry "rsync: $p -> ~/$rel"
        else
            log_dry "copy: $p -> ~/$rel"
        fi
        ((applied++)) || true
        continue
    fi

    mkdir -p "$destdir"

    if [[ -e "$dest" || -L "$dest" ]]; then
        bak="$dest.bak.$BACKUP_TS"
        mv -T "$dest" "$bak"
        ((backed_up++)) || true
    fi

    if [[ -d "$src" ]]; then
        rsync -a --delete "$src/" "$dest/"
    else
        cp -a "$src" "$dest"
    fi

    log_success "Applied: ~/$rel"
    ((applied++)) || true
done

for p in "${removed_paths[@]}"; do
    rel="${p#dots/}"
    dest="$HOME/$rel"

    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ $DRY_RUN -eq 1 ]]; then
            log_dry "Would remove: ~/$rel"
        else
            bak="$dest.bak.$BACKUP_TS"
            mv -T "$dest" "$bak"
            log_success "Removed (backed up): ~/$rel"
            ((backed_up++)) || true
        fi
    fi
done

echo ""
echo "=============================================="
echo "  SUMMARY"
echo "=============================================="
echo "  Applied: $applied files"
echo "  Skipped: $skipped files"
if [[ $DRY_RUN -eq 0 ]]; then
    echo "  Backed up: $backed_up files (suffix: .bak.$BACKUP_TS)"
fi
echo "=============================================="

if [[ $RESTART -eq 1 && $DRY_RUN -eq 0 ]]; then
    echo ""
    log_info "Restarting Quickshell..."

    if systemctl --user is-active --quiet quickshell.service 2>/dev/null; then
        systemctl --user restart quickshell.service
        log_success "Restarted via systemd"
    elif pgrep -x "qs" >/dev/null 2>&1; then
        pkill -x "qs" || true
        sleep 1
        qs -c ii &
        disown
        log_success "Restarted qs process"
    else
        log_warn "Quickshell not running"
    fi
fi

echo ""
if [[ $DRY_RUN -eq 1 ]]; then
    log_info "Dry-run complete. Run without --dry-run to apply changes."
else
    log_success "Update complete!"
    echo "To rollback: ./restore-backup.sh $BACKUP_TS"
fi
echo ""

exit 0
