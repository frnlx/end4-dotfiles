#!/usr/bin/env bash
set -euo pipefail

# ============================================================================
# sync-upstream-files.sh - Pull specific files from upstream
# ============================================================================
# This script pulls updated files from upstream repo to fork,
# skipping AI/Anime/Translator components.
# ============================================================================

FORK_ROOT="/home/frnlx/end4files/end4-dotfiles"
UPSTREAM_ROOT="/home/frnlx/end4files/dots-hyprland"
UPSTREAM_COMMIT="be1838e4"

cd "$FORK_ROOT"

echo "=============================================="
echo "  SYNCING FILES FROM UPSTREAM"
echo "=============================================="
echo "  Upstream: $UPSTREAM_ROOT"
echo "  Target commit: $UPSTREAM_COMMIT"
echo "=============================================="
echo ""

# Files to sync (same list as apply-changes.sh)
files=(
    # Hyprland config
    "dots/.config/hypr/hyprland.conf"
    "dots/.config/hypr/hyprland/env.conf"
    "dots/.config/hypr/hyprland/general.conf"
    "dots/.config/hypr/hyprland/keybinds.conf"
    "dots/.config/hypr/hyprland/shellOverrides/main.conf"
    
    # Quickshell core
    "dots/.config/quickshell/ii/modules/common/Config.qml"
    "dots/.config/quickshell/ii/modules/common/models/NestableObject.qml"
    "dots/.config/quickshell/ii/modules/common/models/hyprland/HyprlandConfigOption.qml"
    "dots/.config/quickshell/ii/modules/common/models/quickToggles/AntiFlashbangToggle.qml"
    "dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml"
    "dots/.config/quickshell/ii/modules/common/widgets/shapes"
    
    # Quickshell UI modules
    "dots/.config/quickshell/ii/modules/ii/background/widgets/clock/CookieClock.qml"
    "dots/.config/quickshell/ii/modules/ii/bar/Workspaces.qml"
    "dots/.config/quickshell/ii/modules/ii/dock/DockAppButton.qml"
    "dots/.config/quickshell/ii/modules/ii/lock/Lock.qml"
    "dots/.config/quickshell/ii/modules/ii/mediaControls/PlayerControl.qml"
    "dots/.config/quickshell/ii/modules/ii/overlay/OverlayContext.qml"
    "dots/.config/quickshell/ii/modules/ii/overlay/OverlayTaskbar.qml"
    "dots/.config/quickshell/ii/modules/ii/overlay/StyledOverlayWidget.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/Overview.qml"
    "dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml"
    "dots/.config/quickshell/ii/modules/ii/sessionScreen/SessionScreen.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRight.qml"
    "dots/.config/quickshell/ii/modules/ii/sidebarRight/nightLight/NightLightDialog.qml"
    "dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelector.qml"
    "dots/.config/quickshell/ii/modules/settings/BackgroundConfig.qml"
    "dots/.config/quickshell/ii/modules/settings/ServicesConfig.qml"
    
    # Waffle panel
    "dots/.config/quickshell/ii/modules/waffle/bar/tasks/TaskAppButton.qml"
    "dots/.config/quickshell/ii/modules/waffle/notificationCenter/CalendarWidget.qml"
    "dots/.config/quickshell/ii/modules/waffle/screenSnip/WRegionSelectionPanel.qml"
    
    # Services
    "dots/.config/quickshell/ii/services/Ai.qml"
    "dots/.config/quickshell/ii/services/GlobalFocusGrab.qml"
    "dots/.config/quickshell/ii/services/HyprlandAntiFlashbangShader.qml"
    "dots/.config/quickshell/ii/services/HyprlandConfig.qml"
    "dots/.config/quickshell/ii/services/HyprlandData.qml"
    "dots/.config/quickshell/ii/services/MprisController.qml"
    "dots/.config/quickshell/ii/services/Network.qml"
    "dots/.config/quickshell/ii/services/SessionWarnings.qml"
    "dots/.config/quickshell/ii/services/Updates.qml"
    "dots/.config/quickshell/ii/services/hyprlandAntiFlashbangShader/anti-flashbang.glsl"
    
    # Scripts
    "dots/.config/quickshell/ii/scripts/colors/applycolor.sh"
    "dots/.config/quickshell/ii/scripts/colors/code/material-code-set-color.sh"
    "dots/.config/quickshell/ii/scripts/colors/switchwall.sh"
    "dots/.config/quickshell/ii/scripts/colors/terminal/kitty-theme.conf"
    "dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py"
    "dots/.config/quickshell/ii/scripts/musicRecognition/recognize-music.sh"
    "dots/.config/quickshell/ii/scripts/thumbnails/generate-thumbnails-magick.sh"
    "dots/.config/quickshell/ii/scripts/ai/gemini-categorize-wallpaper.sh"
    
    # Theming
    "dots/.config/kitty/kitty.conf"
    "dots/.config/matugen/templates/gtk-3.0/gtk.css"
    "dots/.config/matugen/templates/gtk-4.0/gtk.css"
    
    # Assets
    "dots/.config/quickshell/ii/assets/icons/fluent/ethernet-filled.svg"
    
    # Translations
    "dots/.config/quickshell/ii/translations/ru_RU.json"
    
    # Other
    "dots/.config/fish/config.fish"
    
    # Setup scripts (optional - these affect sdata/)
    "sdata/lib/functions.sh"
    "sdata/lib/package-installers.sh"
    "sdata/dist-arch/illogical-impulse-quickshell-git/PKGBUILD"
)

synced=0
failed=0
skipped=0

for file in "${files[@]}"; do
    upstream_file="$UPSTREAM_ROOT/$file"
    fork_file="$FORK_ROOT/$file"
    
    if [[ ! -e "$upstream_file" ]]; then
        echo "[SKIP] Not in upstream: $file"
        ((skipped++))
        continue
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$fork_file")"
    
    # Copy file or directory
    if [[ -d "$upstream_file" ]]; then
        # Check if directory is empty (git submodule placeholder)
        if [[ -z "$(ls -A "$upstream_file" 2>/dev/null)" ]]; then
            echo "[SKIP] Empty directory (likely submodule): $file"
            ((skipped++))
            continue
        fi
        
        if rsync -a --delete "$upstream_file/" "$fork_file/" 2>/dev/null; then
            echo "[SYNC] $file (directory)"
            ((synced++))
        else
            echo "[FAIL] $file"
            ((failed++))
        fi
    else
        if cp -a "$upstream_file" "$fork_file" 2>/dev/null; then
            echo "[SYNC] $file"
            ((synced++))
        else
            echo "[FAIL] $file"
            ((failed++))
        fi
    fi
done

echo ""
echo "=============================================="
echo "  SYNC SUMMARY"
echo "=============================================="
echo "  Synced: $synced files"
echo "  Skipped: $skipped files"
echo "  Failed: $failed files"
echo "=============================================="
echo ""

if [[ $failed -gt 0 ]]; then
    echo "⚠️  Some files failed to sync. Check errors above."
    exit 1
fi

echo "✅ Files synced successfully!"
echo ""
echo "Next steps:"
echo "  1. Review changes: git status && git diff"
echo "  2. Stage bundle: git add upstream-updates/20260319.1/"
echo "  3. Stage synced files: git add dots/ sdata/"
echo "  4. Commit: git commit -m 'feat: upstream sync 2026-03-19'"
echo "  5. Apply to \$HOME: ./upstream-updates/20260319.1/apply-changes.sh --skip-pacman"
echo ""

exit 0
