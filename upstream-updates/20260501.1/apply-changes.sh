#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# apply-changes.sh - Upstream Update Applicator for 20260501.1
# ============================================================================
# Syncs upstream changes to $HOME. Includes optional pacman update step.
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
NC='\033[0m' # No Color

usage() {
    cat <<EOF
Usage: $0 [OPTIONS]

Apply upstream changes from commit be1838e4 to 47235ac4.

Options:
    -n, --dry-run       Show what will be done without making changes
    -r, --restart       Restart Quickshell after applying changes
    -y, --yes           Auto-confirm all prompts (non-interactive)
    --skip-pacman       Skip the pacman update prompt
    --skip-deps         Skip the ./setup install-deps prompt
    -h, --help          Show this help message

Examples:
    $0                  # Interactive mode (prompts for pacman & deps)
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
    echo "  - Hyprland 0.54+ compatibility changes"
    echo "  - Quickshell PKGBUILD with new pinned commit"
    echo "  - New dependency: vulkan-headers (build dep)"
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
                log_info "Skipping pacman update. Proceeding with config changes..."
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
    echo "This update includes Quickshell PKGBUILD changes:"
    echo "  - Pinned commit updated to: 6e17efab"
    echo "  - New build dependency: vulkan-headers"
    echo ""
    echo "You should rebuild Quickshell with the new PKGBUILD."
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
                log_info "Skipping dependency rebuild. Proceeding with config changes..."
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
# FILE LISTS
# ============================================================================

# Files to update (repo-relative paths under dots/)
paths=(
    "dots/.config/fish/config.fish"
    "dots/.config/hypr/custom/env.conf"
    "dots/.config/hypr/custom/execs.conf"
    "dots/.config/hypr/custom/general.conf"
    "dots/.config/hypr/custom/keybinds.conf"
    "dots/.config/hypr/custom/rules.conf"
    "dots/.config/hypr/custom/variables.conf"
    "dots/.config/hypr/hyprland.conf"
    "dots/.config/hypr/hyprland/env.conf"
    "dots/.config/hypr/hyprland/general.conf"
    "dots/.config/hypr/hyprland/keybinds.conf"
    "dots/.config/hypr/hyprland/rules.conf"
    "dots/.config/hypr/hyprland/variables.conf"
    "dots/.config/matugen/templates/gtk-4.0/gtk.css"
    "dots/.config/matugen/templates/hyprland/colors.conf"
    "dots/.config/quickshell/ii/GlobalStates.qml"
    "dots/.config/quickshell/ii/defaults/ai/prompts/ii-Default.md"
    "dots/.config/quickshell/ii/modules/common/Appearance.qml"
    "dots/.config/quickshell/ii/modules/common/Config.qml"
    "dots/.config/quickshell/ii/modules/common/Icons.qml"
    "dots/.config/quickshell/ii/modules/common/functions/ColorUtils.qml"
    "dots/.config/quickshell/ii/modules/common/models/gCloud/GCloudApi.qml"
    "dots/.config/quickshell/ii/modules/common/models/gCloud/GCloudTranslate.qml"
    "dots/.config/quickshell/ii/modules/common/models/gCloud/GCloudVision.qml"
    "dots/.config/quickshell/ii/modules/common/models/gCloud/GCloudVisionResult.qml"
    "dots/.config/quickshell/ii/modules/common/models/quickToggles/NightLightToggle.qml"
    "dots/.config/quickshell/ii/modules/common/utils/MultiTurnProcess.qml"
    "dots/.config/quickshell/ii/modules/common/utils/ScreenshotAction.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ButtonGroup.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ContentPage.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ContentSection.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ContentSubsection.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ErrorShakeAnimation.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/MaskMultiEffect.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/NavigationRailTabArray.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/NoticeBox.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/Revealer.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ScrollEdgeFade.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/SqueezedAnnotationStyledText.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/StyledSlider.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/Toolbar.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/ToolbarPairedFab.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/WindowDialog.qml"
    "dots/.config/quickshell/ii/modules/ii/background/Background.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/SysTray.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/SysTrayItem.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/SysTrayMenu.qml"
    "dots/.config/quickshell/ii/modules/ii/dock/DockApps.qml"
    "dots/.config/quickshell/ii/modules/ii/lock/Lock.qml"
    "dots/.config/quickshell/ii/modules/ii/lock/LockSurface.qml"
    "dots/.config/quickshell/ii/modules/ii/onScreenDisplay/OnScreenDisplay.qml"
    "dots/.config/quickshell/ii/modules/ii/onScreenDisplay/OsdValueIndicator.qml"
    "dots/.config/quickshell/ii/modules/ii/onScreenDisplay/indicators/BrightnessIndicator.qml"
    "dots/.config/quickshell/ii/modules/ii/onScreenDisplay/indicators/GammaIndicator.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/SearchItem.qml"
    "dots/.config/quickshell/ii/modules/ii/regionSelector/RectCornersSelectionDetails.qml"
    "dots/.config/quickshell/ii/modules/ii/regionSelector/RegionSelection.qml"
    "dots/.config/quickshell/ii/modules/ii/regionSelector/RegionSelector.qml"
    "dots/.config/quickshell/ii/modules/ii/screenCorners/ScreenCorners.qml"
    "dots/.config/quickshell/ii/modules/ii/screenTranslator/ScreenTextOverlay.qml"
    "dots/.config/quickshell/ii/modules/ii/screenTranslator/ScreenTranslator.qml"
    "dots/.config/quickshell/ii/modules/ii/screenTranslator/ScreenTranslatorPanel.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/QuickSliders.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/bluetoothDevices/BluetoothDeviceItem.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/nightLight/NightLightDialog.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/classicStyle/NightLight.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/volumeMixer/VolumeMixerEntry.qml"
    "dots/.config/quickshell/ii/modules/ii/verticalBar/BatteryIndicator.qml"
    "dots/.config/quickshell/ii/modules/ii/verticalBar/VerticalBarContent.qml"
    "dots/.config/quickshell/ii/modules/ii/verticalBar/VerticalClockWidget.qml"
    "dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelectorContent.qml"
    "dots/.config/quickshell/ii/modules/settings/BackgroundConfig.qml"
    "dots/.config/quickshell/ii/modules/waffle/actionCenter/nightLight/NightLightControl.qml"
    "dots/.config/quickshell/ii/modules/waffle/lock/WaffleLock.qml"
    "dots/.config/quickshell/ii/modules/waffle/looks/WIcons.qml"
    "dots/.config/quickshell/ii/modules/waffle/looks/WToolbar.qml"
    "dots/.config/quickshell/ii/modules/waffle/startMenu/startPage/StartPageApps.qml"
    "dots/.config/quickshell/ii/panelFamilies/IllogicalImpulseFamily.qml"
    "dots/.config/quickshell/ii/panelFamilies/WaffleFamily.qml"
    "dots/.config/quickshell/ii/scripts/colors/applycolor.sh"
    "dots/.config/quickshell/ii/scripts/colors/terminal/kitty-theme.conf"
    "dots/.config/quickshell/ii/scripts/colors/terminal/sequences.txt"
    "dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py"
    "dots/.config/quickshell/ii/scripts/images/text-color-venv.sh"
    "dots/.config/quickshell/ii/scripts/images/text_color.py"
    "dots/.config/quickshell/ii/scripts/musicRecognition/recognize-music.sh"
    "dots/.config/quickshell/ii/services/Brightness.qml"
    "dots/.config/quickshell/ii/services/GoogleCloud.qml"
    "dots/.config/quickshell/ii/services/Hyprsunset.qml"
    "dots/.config/quickshell/ii/services/KeyringStorage.qml"
    "dots/.config/quickshell/ii/services/LauncherSearch.qml"
    "dots/.config/quickshell/ii/services/TrayService.qml"
    "dots/.config/quickshell/ii/services/gCloud/token-from-key-venv.sh"
    "dots/.config/quickshell/ii/services/gCloud/token_from_key.py"
    "dots/.config/quickshell/ii/translations/en_US.json"
    "dots/.config/quickshell/ii/translations/es_MX.json"
    "dots/.config/quickshell/ii/translations/fr_FR.json"
    "dots/.config/quickshell/ii/translations/ru_RU.json"
    "dots/.config/quickshell/ii/translations/zh_CN.json"
    "dots/.config/starship.toml"
)

# Files that were removed upstream (back up and delete)
removed_paths=(
    "dots/.config/quickshell/ii/modules/ii/verticalBar/VerticalDateWidget.qml"
)

# ============================================================================
# MAIN EXECUTION
# ============================================================================

echo ""
echo "=============================================="
echo "  UPSTREAM UPDATE: 20260501.1"
echo "=============================================="
echo "  Commits: be1838e4 → 47235ac4 (187 commits)"
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
        if [[ $DRY_RUN -eq 1 ]]; then
            log_dry "rsync: $p → ~/$rel"
        else
            log_dry "copy: $p → ~/$rel"
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
        echo "  The Quickshell PKGBUILD was updated (commit: 6e17efab)"
        echo "  Run './setup install-deps' manually to rebuild"
        echo ""
    fi
    echo "To restart Quickshell: pkill qs; qs -c ii"
    echo "To rollback: ./restore-backup.sh $BACKUP_TS"
fi
echo ""

exit 0
