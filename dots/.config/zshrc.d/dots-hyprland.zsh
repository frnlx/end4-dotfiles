# Use the generated color scheme (only if not using static kitty theme)

if test -f ~/.local/state/quickshell/user/generated/terminal/sequences.txt; then
    # Check if kitty is using static Dracula theme
    kitty_mode=$(jq -r '.appearance.wallpaperTheming.kittyThemeMode // "auto"' ~/.config/illogical-impulse/config.json 2>/dev/null)
    if [ "$kitty_mode" != "dracula" ]; then
        cat ~/.local/state/quickshell/user/generated/terminal/sequences.txt
    fi
fi
