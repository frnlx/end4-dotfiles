#!/usr/bin/env bash
# set-kitty-theme.sh - Toggle or set kitty terminal theme mode
# Usage: set-kitty-theme.sh [auto|dracula|toggle|apply]
#   auto    - Use wallpaper-generated colors
#   dracula - Use static Dracula theme
#   toggle  - Toggle between auto and dracula
#   apply   - Re-apply the current theme setting (no change to config)

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
CONFIG_FILE="$XDG_CONFIG_HOME/illogical-impulse/config.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

get_current_mode() {
    if [ -f "$CONFIG_FILE" ]; then
        jq -r '.appearance.wallpaperTheming.kittyThemeMode // "auto"' "$CONFIG_FILE"
    else
        echo "auto"
    fi
}

set_mode() {
    local mode="$1"
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "Config file not found: $CONFIG_FILE"
        exit 1
    fi
    jq --arg mode "$mode" '.appearance.wallpaperTheming.kittyThemeMode = $mode' "$CONFIG_FILE" > "$CONFIG_FILE.tmp" \
        && mv "$CONFIG_FILE.tmp" "$CONFIG_FILE"
    echo "Set kitty theme mode to: $mode"
}

apply_theme() {
    local STATE_DIR="$XDG_STATE_HOME/quickshell"
    local OUTPUT_DIR="$STATE_DIR/user/generated/terminal"
    mkdir -p "$OUTPUT_DIR"

    local mode
    mode=$(get_current_mode)

    if [ "$mode" = "dracula" ]; then
        if [ -f "$SCRIPT_DIR/terminal/kitty-dracula.conf" ]; then
            cp "$SCRIPT_DIR/terminal/kitty-dracula.conf" "$OUTPUT_DIR/kitty-theme.conf"
            rm -f "$OUTPUT_DIR/sequences.txt"
            echo "Applied Dracula theme"
        else
            echo "Dracula theme file not found!"
            exit 1
        fi
    else
        # For auto mode, regenerate from current material colors
        local COLORS_FILE="$STATE_DIR/user/generated/material_colors.scss"
        local TEMPLATE_FILE="$SCRIPT_DIR/terminal/kitty-theme.conf"
        
        if [ ! -f "$COLORS_FILE" ]; then
            echo "No material colors found. Switch wallpaper first to generate colors."
            exit 1
        fi
        
        if [ ! -f "$TEMPLATE_FILE" ]; then
            echo "Template file not found: $TEMPLATE_FILE"
            exit 1
        fi
        
        # Parse material_colors.scss
        local colornames colorstrings
        colornames=$(cut -d: -f1 "$COLORS_FILE")
        colorstrings=$(cut -d: -f2 "$COLORS_FILE" | cut -d ' ' -f2 | cut -d ";" -f1)
        
        local IFS=$'\n'
        local colorlist=($colornames)
        local colorvalues=($colorstrings)
        
        # Copy template and apply colors
        cp "$TEMPLATE_FILE" "$OUTPUT_DIR/kitty-theme.conf"
        for i in "${!colorlist[@]}"; do
            sed -i "s/${colorlist[$i]} #/${colorvalues[$i]#\#}/g" "$OUTPUT_DIR/kitty-theme.conf"
        done
        
        echo "Applied auto-generated theme"
    fi

    # Signal kitty to reload config (kitty reloads automatically when included files change)
    # But we can also send SIGUSR1 to force reload
    pkill -SIGUSR1 kitty 2>/dev/null || true
}

main() {
    local action="${1:-apply}"

    case "$action" in
        auto)
            set_mode "auto"
            apply_theme
            ;;
        dracula)
            set_mode "dracula"
            apply_theme
            ;;
        toggle)
            local current
            current=$(get_current_mode)
            if [ "$current" = "dracula" ]; then
                set_mode "auto"
            else
                set_mode "dracula"
            fi
            apply_theme
            ;;
        apply)
            apply_theme
            ;;
        get)
            get_current_mode
            ;;
        *)
            echo "Usage: $0 [auto|dracula|toggle|apply|get]"
            exit 1
            ;;
    esac
}

main "$@"
