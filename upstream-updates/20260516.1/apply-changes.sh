#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# apply-changes.sh - Upstream Update Applicator for 20260516.1
# ============================================================================
# Syncs upstream changes to $HOME. Handles Hyprland .conf -> .lua migration.
# Includes optional pacman update step and dependency rebuilding.
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

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Apply upstream changes from commit 47235ac4 to c0706258.

This update includes a major Hyprland config migration from .conf to .lua files.
Your old configs will be backed up before any changes.

Options:
    -n, --dry-run       Show what will be done without making changes
    -r, --restart       Restart Quickshell after applying changes
    -y, --yes           Auto-confirm all prompts (non-interactive)
    --skip-pacman       Skip the pacman update prompt
    --skip-deps         Skip the ./setup install-deps prompt
    -h, --help          Show this help message

Examples:
    $0                  # Interactive mode
    $0 --dry-run        # Preview changes
    $0 -y --restart     # Auto-yes, apply and restart
    $0 --skip-pacman --skip-deps  # Skip all prompts, just apply configs
EOF
}

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_dry() { echo -e "${YELLOW}[DRY-RUN]${NC} $1"; }

# Parse arguments
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

# ============================================================================
# PACMAN UPDATE PROMPT
# ============================================================================
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
    echo "This upstream update includes:"
    echo "  - Quickshell PKGBUILD fixes"
    echo "  - New dependency: libunwind-devel (for cpptrace)"
    echo "  - Fedora dependencies reworked"
    echo ""
    echo "It's recommended to update system packages BEFORE applying config changes."
    echo ""

    if [[ $DRY_RUN -eq 1 ]]; then
        log_dry "Would prompt: Run 'sudo pacman -Syyu' now?"
        return
    fi

    if [[ $AUTO_YES -eq 1 ]]; then
        log_info "Auto-yes mode: Running pacman -Syyu"
        run_pacman_update
        return
    fi

    echo "Options:"
    echo "  [1] Run 'sudo pacman -Syyu' now (recommended)"
    echo "  [2] Skip pacman update (I already updated or will do it later)"
    echo "  [3] Abort script"
    echo ""
    
    while true; do
        read -rp "Choose an option [1/2/3]: " choice
        case "$choice" in
            1)
                run_pacman_update
                break
                ;;
            2)
                log_info "Skipping pacman update. Proceeding..."
                break
                ;;
            3)
                log_info "Aborted by user."
                exit 0
                ;;
            *)
                log_warn "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

run_pacman_update() {
    log_info "Running system update..."
    echo ""
    
    if sudo pacman -Syyu; then
        log_success "System packages updated successfully"
    else
        log_error "pacman update failed!"
        echo ""
        read -rp "Continue with config changes anyway? [y/N]: " cont
        if [[ ! "$cont" =~ ^[Yy]$ ]]; then
            log_info "Aborted."
            exit 1
        fi
    fi
    echo ""
}

# ============================================================================
# INSTALL-DEPS PROMPT
# ============================================================================
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
    echo "This update includes PKGBUILD / setup changes."
    echo "You should rebuild dependencies via the setup script."
    echo ""

    if [[ $DRY_RUN -eq 1 ]]; then
        log_dry "Would prompt: Run './setup install-deps' now?"
        return
    fi

    if [[ $AUTO_YES -eq 1 ]]; then
        log_info "Auto-yes mode: Running ./setup install-deps"
        run_install_deps
        return
    fi

    echo "Options:"
    echo "  [1] Run './setup install-deps' now (recommended)"
    echo "  [2] Skip rebuild (I'll do it manually later)"
    echo "  [3] Abort script"
    echo ""
    
    while true; do
        read -rp "Choose an option [1/2/3]: " choice
        case "$choice" in
            1)
                run_install_deps
                break
                ;;
            2)
                log_info "Skipping dependency rebuild. Proceeding..."
                break
                ;;
            3)
                log_info "Aborted by user."
                exit 0
                ;;
            *)
                log_warn "Invalid choice. Please enter 1, 2, or 3."
                ;;
        esac
    done
}

run_install_deps() {
    log_info "Running ./setup install-deps..."
    echo ""
    
    if [[ ! -f "$REPO_ROOT/setup" ]]; then
        log_error "./setup script not found at: $REPO_ROOT/setup"
        echo ""
        read -rp "Continue without rebuilding? [y/N]: " cont
        if [[ ! "$cont" =~ ^[Yy]$ ]]; then
            log_info "Aborted."
            exit 1
        fi
        return
    fi
    
    if cd "$REPO_ROOT" && ./setup install-deps; then
        log_success "Dependencies installed/rebuilt successfully"
    else
        log_error "./setup install-deps failed!"
        echo ""
        read -rp "Continue with config changes anyway? [y/N]: " cont
        if [[ ! "$cont" =~ ^[Yy]$ ]]; then
            log_info "Aborted."
            exit 1
        fi
    fi
    echo ""
}

# ============================================================================
# CONFIRMATION PROMPT
# ============================================================================
if [[ $AUTO_YES -eq 0 && $DRY_RUN -eq 0 ]]; then
    echo ""
    echo "=============================================="
    echo "  UPSTREAM UPDATE: 20260516.1"
    echo "=============================================="
    echo ""
    echo "WARNING: This update MIGRATES Hyprland config"
    echo "from .conf files to .lua files."
    echo ""
    echo "Your old configs will be backed up with suffix:"
    echo "  .bak.$BACKUP_TS"
    echo ""
    echo "After applying, you MUST log out and back in"
    echo "for the new Hyprland lua config to take effect."
    echo ""
    read -rp "Continue? [y/N]: " cont
    if [[ ! "$cont" =~ ^[Yy]$ ]]; then
        log_info "Aborted."
        exit 0
    fi
fi

# ============================================================================
# FILE LISTS
# ============================================================================

# Files to update (repo-relative paths under dots/)
paths=(
    # --- New Lua Hyprland configs ---
    "dots/.config/hypr/custom/env.lua"
    "dots/.config/hypr/custom/execs.lua"
    "dots/.config/hypr/custom/general.lua"
    "dots/.config/hypr/custom/keybinds.lua"
    "dots/.config/hypr/custom/rules.lua"
    "dots/.config/hypr/custom/variables.lua"
    "dots/.config/hypr/hyprland.lua"
    "dots/.config/hypr/hyprland/colors.lua"
    "dots/.config/hypr/hyprland/env.lua"
    "dots/.config/hypr/hyprland/execs.lua"
    "dots/.config/hypr/hyprland/general.lua"
    "dots/.config/hypr/hyprland/keybinds.lua"
    "dots/.config/hypr/hyprland/lib/init.lua"
    "dots/.config/hypr/hyprland/rules.lua"
    "dots/.config/hypr/hyprland/services/create_custom_config.lua"
    "dots/.config/hypr/hyprland/services/init.lua"
    "dots/.config/hypr/hyprland/shellOverrides/main.lua"
    "dots/.config/hypr/hyprland/variables.lua"
    # --- Modified files ---
    "dots/.config/hypr/hypridle.conf"
    "dots/.config/hypr/hyprland/scripts/fuzzel-emoji.sh"
    "dots/.config/matugen/config.toml"
    "dots/.config/matugen/templates/gtk-4.0/gtk.css"
    "dots/.config/matugen/templates/hyprland/colors.lua"
    "dots/.config/quickshell/ii/modules/common/panels/lock/LockScreen.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/CliphistImage.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/DirectoryIcon.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/NotificationAppIcon.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/StyledImage.qml"
    "dots/.config/quickshell/ii/modules/ii/background/Background.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/UtilButtons.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/Workspaces.qml"
    "dots/.config/quickshell/ii/modules/ii/cheatsheet/Cheatsheet.qml"
    "dots/.config/quickshell/ii/modules/ii/cheatsheet/CheatsheetKeybinds.qml"
    "dots/.config/quickshell/ii/modules/ii/cheatsheet/CheatsheetKeybindsCategory.qml"
    "dots/.config/quickshell/ii/modules/ii/lock/Lock.qml"
    "dots/.config/quickshell/ii/modules/ii/mediaControls/PlayerControl.qml"
    "dots/.config/quickshell/ii/modules/ii/notificationPopup/NotificationPopup.qml"
    "dots/.config/quickshell/ii/modules/ii/overlay/floatingImage/FloatingImage.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/Overview.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/OverviewWindow.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRightContent.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/volumeMixer/VolumeMixerEntry.qml"
    "dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperDirectoryItem.qml"
    "dots/.config/quickshell/ii/modules/waffle/lock/WaffleLock.qml"
    "dots/.config/quickshell/ii/modules/waffle/notificationCenter/WSingleNotification.qml"
    "dots/.config/quickshell/ii/modules/waffle/taskView/TaskViewContent.qml"
    "dots/.config/quickshell/ii/modules/waffle/taskView/TaskViewWindow.qml"
    "dots/.config/quickshell/ii/modules/waffle/taskView/TaskViewWorkspace.qml"
    "dots/.config/quickshell/ii/scripts/colors/applycolor.sh"
    "dots/.config/quickshell/ii/scripts/colors/code/material-code-set-color.sh"
    "dots/.config/quickshell/ii/scripts/colors/switchwall.sh"
    "dots/.config/quickshell/ii/scripts/colors/terminal/kitty-theme.conf"
    "dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py"
    "dots/.config/quickshell/ii/services/HyprlandConfig.qml"
    "dots/.config/quickshell/ii/services/HyprlandKeybinds.qml"
    "dots/.config/quickshell/ii/services/Hyprsunset.qml"
    "dots/.config/quickshell/ii/services/LauncherSearch.qml"
    "dots/.config/quickshell/ii/services/MaterialThemeLoader.qml"
    "dots/.config/quickshell/ii/services/Wallpapers.qml"
    "dots/.config/quickshell/ii/services/hyprlandAntiFlashbangShader/anti-flashbang.glsl"
)

# Files that were removed upstream (back up and delete from $HOME)
removed_paths=(
    "dots/.config/hypr/hyprland.conf"
    "dots/.config/hypr/hyprland/colors.conf"
    "dots/.config/hypr/hyprland/env.conf"
    "dots/.config/hypr/hyprland/execs.conf"
    "dots/.config/hypr/hyprland/general.conf"
    "dots/.config/hypr/hyprland/keybinds.conf"
    "dots/.config/hypr/hyprland/rules.conf"
    "dots/.config/hypr/hyprland/variables.conf"
    "dots/.config/hypr/hyprland/scripts/workspace_action.sh"
    "dots/.config/hypr/hyprland/scripts/zoom.sh"
    "dots/.config/hypr/hyprland/shellOverrides/main.conf"
    "dots/.config/matugen/templates/hyprland/colors.conf"
    "dots/.config/quickshell/ii/scripts/hyprland/get_keybinds.py"
    "dots/.config/quickshell/ii/scripts/kvantum/adwsvg.py"
    "dots/.config/quickshell/ii/scripts/kvantum/adwsvgDark.py"
    "dots/.config/quickshell/ii/scripts/kvantum/changeAdwColors.py"
    "dots/.config/quickshell/ii/scripts/kvantum/materialQT.sh"
)

# ============================================================================
# MAIN EXECUTION
# ============================================================================

echo ""
echo "=============================================="
echo "  UPSTREAM UPDATE: 20260516.1"
echo "=============================================="
echo "  Commits: 47235ac4 -> c0706258 (74 commits)"
echo "  Repo root: $REPO_ROOT"
echo "=============================================="
echo ""

if [[ $DRY_RUN -eq 1 ]]; then
    log_warn "DRY-RUN MODE - No changes will be made"
    echo ""
fi

# Step 1: Pacman update prompt
prompt_pacman_update

# Step 2: Install-deps prompt
prompt_install_deps

# Step 3: Apply file changes
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

    # Strip "dots/" prefix for destination
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

    # Create destination directory
    mkdir -p "$destdir"

    # Backup existing file/directory
    if [[ -e "$dest" || -L "$dest" ]]; then
        bak="$dest.bak.$BACKUP_TS"
        mv -T "$dest" "$bak"
        ((backed_up++)) || true
    fi

    # Copy or rsync
    if [[ -d "$src" ]]; then
        rsync -a --delete "$src/" "$dest/"
    else
        cp -a "$src" "$dest"
    fi

    log_success "Applied: ~/$rel"
    ((applied++)) || true
done

# Handle removed files
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

# Special: backup hyprland.conf at root if it still exists (not caught by removed_paths due to being replaced)
# Actually it's in removed_paths. But also handle the case where hyprland.lua already exists
if [[ -e "$HOME/.config/hypr/hyprland.conf" ]]; then
    if [[ $DRY_RUN -eq 1 ]]; then
        log_dry "Would backup and remove: ~/.config/hypr/hyprland.conf"
    else
        bak="$HOME/.config/hypr/hyprland.conf.bak.$BACKUP_TS"
        mv -T "$HOME/.config/hypr/hyprland.conf" "$bak"
        log_success "Removed (backed up): ~/.config/hypr/hyprland.conf"
        ((backed_up++)) || true
    fi
fi

# Summary
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

# Post-apply warnings
if [[ $DRY_RUN -eq 0 ]]; then
    echo ""
    log_warn "IMPORTANT: You must log out and log back in for the new"
    log_warn "Hyprland Lua config to take effect. Simply reloading"
    log_warn "Hyprland is NOT sufficient for this migration."
    echo ""
    log_info "Old .conf files in ~/.config/hypr/custom/ were left in place"
    log_info "for reference but will not be loaded by the new Lua config."
    log_info "Port your customizations to the new .lua files when ready."
fi

# Step 4: Restart Quickshell if requested
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
    echo ""
    if [[ $SKIP_DEPS -eq 1 ]]; then
        echo "REMINDER: You skipped ./setup install-deps"
        echo "  This update requires newer dependencies."
        echo "  Run './setup install-deps' manually."
        echo ""
    fi
    echo "To rollback: ./restore-backup.sh $BACKUP_TS"
fi
echo ""

exit 0