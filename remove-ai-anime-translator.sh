#!/bin/bash
# Script to remove AI Chat, Anime/Booru, and Translator components
# from an existing illogical-impulse installation on Arch Linux

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QS_CONFIG="$HOME/.config/quickshell/ii"
HYPR_CONFIG="$HOME/.config/hypr"

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Remove AI, Anime, and Translator from illogical-impulse    ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "This script will:"
echo "  • Remove AI Chat, Anime/Booru, and Translator components"
echo "  • Update config files to remove references"
echo "  • Optionally remove translate-shell package"
echo "  • Restart Quickshell"
echo ""
read -p "Continue? [y/N] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 1
fi

echo ""
echo "Step 1: Removing AI components..."
rm -rf "$QS_CONFIG/services/ai/" 2>/dev/null || true
rm -f "$QS_CONFIG/services/Ai.qml" 2>/dev/null || true
rm -rf "$QS_CONFIG/modules/ii/sidebarLeft/aiChat/" 2>/dev/null || true
rm -f "$QS_CONFIG/modules/ii/sidebarLeft/AiChat.qml" 2>/dev/null || true
rm -rf "$QS_CONFIG/scripts/ai/" 2>/dev/null || true
rm -rf "$QS_CONFIG/defaults/ai/" 2>/dev/null || true
rm -rf "$HYPR_CONFIG/scripts/ai/" 2>/dev/null || true
echo "  ✓ AI components removed"

echo ""
echo "Step 2: Removing Anime/Booru components..."
rm -f "$QS_CONFIG/services/Booru.qml" 2>/dev/null || true
rm -f "$QS_CONFIG/services/BooruResponseData.qml" 2>/dev/null || true
rm -rf "$QS_CONFIG/modules/ii/sidebarLeft/anime/" 2>/dev/null || true
rm -f "$QS_CONFIG/modules/ii/sidebarLeft/Anime.qml" 2>/dev/null || true
rm -rf "$QS_CONFIG/scripts/colors/random/" 2>/dev/null || true
echo "  ✓ Anime/Booru components removed"

echo ""
echo "Step 3: Removing Translator components..."
rm -rf "$QS_CONFIG/modules/ii/sidebarLeft/translator/" 2>/dev/null || true
rm -f "$QS_CONFIG/modules/ii/sidebarLeft/Translator.qml" 2>/dev/null || true
echo "  ✓ Translator components removed"

echo ""
echo "Step 4: Cleaning up cached data..."
rm -rf "$HOME/.local/state/quickshell/user/ai/" 2>/dev/null || true
rm -rf "$HOME/.cache/quickshell/media/boorus/" 2>/dev/null || true
echo "  ✓ Cached data cleaned"

echo ""
echo "Step 5: Updating config files..."
DOTS_DIR="$SCRIPT_DIR/dots"

if [[ -d "$DOTS_DIR" ]]; then
    # Copy updated QML files
    cp "$DOTS_DIR/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeftContent.qml" \
       "$QS_CONFIG/modules/ii/sidebarLeft/" 2>/dev/null && echo "  ✓ SidebarLeftContent.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/common/Config.qml" \
       "$QS_CONFIG/modules/common/" 2>/dev/null && echo "  ✓ Config.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/common/Directories.qml" \
       "$QS_CONFIG/modules/common/" 2>/dev/null && echo "  ✓ Directories.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/common/Persistent.qml" \
       "$QS_CONFIG/modules/common/" 2>/dev/null && echo "  ✓ Persistent.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/ii/bar/LeftSidebarButton.qml" \
       "$QS_CONFIG/modules/ii/bar/" 2>/dev/null && echo "  ✓ LeftSidebarButton.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/settings/GeneralConfig.qml" \
       "$QS_CONFIG/modules/settings/" 2>/dev/null && echo "  ✓ GeneralConfig.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/settings/BackgroundConfig.qml" \
       "$QS_CONFIG/modules/settings/" 2>/dev/null && echo "  ✓ BackgroundConfig.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/settings/QuickConfig.qml" \
       "$QS_CONFIG/modules/settings/" 2>/dev/null && echo "  ✓ QuickConfig.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/services/LauncherSearch.qml" \
       "$QS_CONFIG/services/" 2>/dev/null && echo "  ✓ LauncherSearch.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/modules/ii/background/widgets/clock/CookieClock.qml" \
       "$QS_CONFIG/modules/ii/background/widgets/clock/" 2>/dev/null && echo "  ✓ CookieClock.qml"
    
    cp "$DOTS_DIR/.config/quickshell/ii/scripts/colors/switchwall.sh" \
       "$QS_CONFIG/scripts/colors/" 2>/dev/null && echo "  ✓ switchwall.sh"
    
    cp "$DOTS_DIR/.config/quickshell/ii/welcome.qml" \
       "$QS_CONFIG/" 2>/dev/null && echo "  ✓ welcome.qml"
    
    cp "$DOTS_DIR/.config/hypr/hyprland/keybinds.conf" \
       "$HYPR_CONFIG/hyprland/" 2>/dev/null && echo "  ✓ keybinds.conf"
else
    echo "  ⚠ Warning: dots directory not found at $DOTS_DIR"
    echo "    Config files not updated. You may need to copy them manually."
fi

echo ""
read -p "Step 6: Remove translate-shell package? [y/N] " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if pacman -Qi translate-shell &>/dev/null; then
        sudo pacman -Rns translate-shell --noconfirm
        echo "  ✓ translate-shell removed"
    else
        echo "  ℹ translate-shell is not installed"
    fi
else
    echo "  ⊘ Skipped"
fi

echo ""
read -p "Step 7: Restart Quickshell now? [Y/n] " -n 1 -r
echo ""
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    echo "  Restarting Quickshell..."
    pkill -x quickshell 2>/dev/null || true
    sleep 1
    nohup quickshell >/dev/null 2>&1 &
    echo "  ✓ Quickshell restarted"
else
    echo "  ⊘ Skipped (run 'quickshell -k; quickshell &' to restart manually)"
fi

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║  Done! AI, Anime, and Translator have been removed.         ║"
echo "╚══════════════════════════════════════════════════════════════╝"
