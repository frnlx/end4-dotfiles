# end4-dotfiles (Personalized Branch)

Personalized fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) ("illogical-impulse"), featuring removed AI/Anime/Translator bloat plus custom daily-driver enhancements.

> [!NOTE]
> Looking for the clean stripped fork without personal modifications? Switch to the **[`main`](https://github.com/frnlx/end4-dotfiles/tree/main)** branch.

---

## ✦ Overview & Upstream Architecture

- **Compositor**: [Hyprland](https://github.com/hyprwm/hyprland) (v0.55+ with Lua configuration)
- **Widget & Shell**: [Quickshell](https://quickshell.outfoxxed.me/) (QtQuick/QML-based status bar, dock, and overlay panels)
- **Color Engine**: [Matugen](https://github.com/InioX/matugen) (Dynamic Material You palettes extracted from wallpaper)
- **Official Documentation**: [ii.clsty.link Wiki](https://ii.clsty.link/en/ii-qs/01setup/)

### Essential Keybinds
| Keybind | Action |
| :--- | :--- |
| `Super` + `Enter` | Launch Terminal (Kitty) |
| `Super` + `/` | Keybinds Cheatsheet |
| `Super` + `V` | Clipboard History Manager |
| `Super` + `W` | Wallpaper Selector |
| `Super` + `D` / `Super` (tap) | App Launcher / Overview |

---

## ✦ Fork Features & Customizations

### 1. Clean Baseline (Fork Exclusions)
Like the `main` branch, all AI Chat (Gemini/OpenAI/Ollama), Anime/Booru browser widgets, and Translation tools are permanently stripped out. See [`upstream-updates/fork-exclusions.md`](upstream-updates/fork-exclusions.md).

### 2. Personal Enhancements on this Branch
- 🌡️ **CPU Temperature Sensor**:
  - Integrated directly into `ResourceUsage.qml` and `ResourcesPopup.qml`.
  - Automatically queries kernel `hwmon` drivers (`k10temp`, `coretemp`, `zenpower`) to display live processor temperatures.
- 🎨 **Kitty Dracula Theming Switch**:
  - Dedicated toggle switch in the left sidebar (*"Kitty Terminal Theme / Use Dracula theme"*).
  - Cleanly bypasses dynamic wallpaper OSC escape sequences in Fish and Zsh when Dracula mode is selected.
  - Automatically updates `kitty-theme.conf` and reloads Kitty via `SIGUSR1`.

---

## ✦ Installation & Updates

### Fresh Installation
```bash
git clone -b personalized https://github.com/frnlx/end4-dotfiles.git
cd end4-dotfiles
./setup install
```

### Applying Incremental Updates
Update bundles are provided in `upstream-updates/YYYYMMDD.n/`:
```bash
cd upstream-updates/<LATEST_BUNDLE>/
./apply-changes.sh --dry-run   # Test changes safely
./apply-changes.sh --restart   # Apply and reload Quickshell
```

---

## ✦ Credits & Acknowledgements
- [end-4](https://github.com/end-4) for the incredible [dots-hyprland](https://github.com/end-4/dots-hyprland) desktop shell.
- [clsty](https://github.com/clsty) for the installer and documentation.
- [outfoxxed](https://github.com/outfoxxed) for Quickshell.
