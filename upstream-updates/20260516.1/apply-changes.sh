#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# apply-changes.sh - Upstream Update Applicator for 20260516.1
# ============================================================================
# Syncs upstream changes to $HOME. Handles Hyprland .conf -> .lua migration.
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
BACKUP_TS="$(date +%s)"

# Defaults
DRY_RUN=0
RESTART=0
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
    -h, --help          Show this help message

Examples:
    $0                  # Interactive mode
    $0 --dry-run        # Preview changes
    $0 -y --restart     # Auto-yes, apply and restart
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
        -h|--help) usage; exit 0 ;;
        *) log_error "Unknown argument: $1"; usage; exit 2 ;;
    esac
done

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
    "dots/.config/quickshell/ii/modules/common/Config.qml"
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
    "dots/.config/quickshell/ii/modules/settings/InterfaceConfig.qml"
    "dots/.config/quickshell/ii/modules/settings/QuickConfig.qml"
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
    # --- Setup/repo files ---
    "sdata/dist-arch/illogical-impulse-quickshell-git/PKGBUILD"
    "sdata/dist-fedora/README.md"
    "sdata/dist-fedora/feddeps.toml"
    "sdata/dist-fedora/install-deps.sh"
    "sdata/subcmd-install/3.files-exp.yaml"
    "sdata/subcmd-install/3.files-legacy.sh"
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

# Step 1: Apply file changes
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

# Step 2: Restart Quickshell if requested
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
    echo "To rollback: ./restore-backup.sh $BACKUP_TS"
fi
echo ""

exit 0
