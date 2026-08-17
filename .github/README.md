# end4-dotfiles (Clean Stripped Fork)

A clean, de-bloated fork of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) ("illogical-impulse"), a Material Design 3 desktop environment built on **Hyprland** and **Quickshell**.

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

## ✦ What This Fork Changes (`main` branch)

This repository maintains a clean, lightweight version of `end-4`'s dotfiles with the following principles:

1. **Permanently Stripped Components**:
   - 🚫 **AI Integrations**: Removed all AI sidebars, chat interfaces, OpenAI/Gemini/Ollama API strategies, and prompts.
   - 🚫 **Anime & Booru**: Removed Booru/Danbooru/Konachan browsers, downloader scripts, and wallpaper fetchers.
   - 🚫 **Translator**: Removed screen translator overlays and Google translation pipelines.
   - *(See [`upstream-updates/fork-exclusions.md`](upstream-updates/fork-exclusions.md) for the complete exclusion manifest).*

2. **Clean Upstream Tracking**:
   - Fully synchronized with upstream `dots-hyprland` updates (including Lua migration and Quickshell widget refactors).
   - Modular update bundles stored in [`upstream-updates/`](upstream-updates/) for safe inspection and rollback.
   - **Zero personal styling or extra modifications** — strictly a clean, debloated baseline.

---

## ✦ Looking for Personal Customizations?

Check out the **[`personalized`](https://github.com/frnlx/end4-dotfiles/tree/personalized)** branch for my daily-driver configuration, which adds:

- 🌡️ **CPU Temperature Monitor**: Native `hwmon` sensor reading (`k10temp`/`coretemp`/`zenpower`) in the Resource Usage popup.
- 🎨 **Kitty Dracula Theme Toggle**: Left sidebar switch and shell gating to toggle between static Dracula dark theme and dynamic wallpaper-generated palettes.

---

## ✦ Installation & Upstream Updates

### Fresh Installation
Clone the repository and run the installer:
```bash
git clone https://github.com/frnlx/end4-dotfiles.git
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
