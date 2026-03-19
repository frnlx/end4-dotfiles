# Upstream Merge: Hyprland 0.54 Compat, Anti-Flashbang, Fixes

**Commit range:** `4ff34354` → `be1838e4`
**Date range:** 2026-01-28 to 2026-03-19
**Total commits:** 110

## Summary

Major update including Hyprland 0.54+ compatibility (removed deprecated hyprexpo plugin), new anti-flashbang shader feature, game mode persistence, numerous bug fixes for dock/lock screen/media controls, and Russian translation updates.

## Breaking Changes

- **Hyprland 0.54+** — Removed deprecated `hyprexpo` plugin config from `general.conf`
- **Quickshell PKGBUILD** — Pinned commit updated to `6e17efab`, requires rebuild
- **vulkan-headers** — Added as build dependency for Quickshell

## Key Changes

### Critical (Hyprland/Core)
- **48fec445**: hyprland: nuke unused plugin config to fix error on 0.54
- **060b8693**: hyprland: adjust some effects
- **5cbf5608**: keybinds: add splitratio bindings
- **2af409b1**: Add fallback to xcb for QT_QPA_PLATFORM (wayland;xcb)

### New Features
- **be1838e4**: add anti-flashbang with shader
- **9a11a0d8**: make game mode persistent (#3084)
- **8190c3b9**: Allow centering widgets in overlay using right-click (#2967)
- **3d9f5103**: settings: allow crazy background clock sizes

### Bug Fixes
- **1dcf90ac**: Fix dock first launch (#2707)
- **7013893c**: fix(quickshell): fix qs crashing when sidebar is detached while in use (#3069)
- **5710fbb3**: fix player track change slow art update (#2036)
- **4fc56f6c**: Fix wifi signal strength bar display (#3063)
- **21328291**: fix(quickshell): bug temp lock screen workspaces (#2942)
- **33bd0420**: fix: music recognition for songrec 0.6.3+ (#3027)
- **9bbfef19**: fixed thumbnail urlencode for file names with (,),*
- **a7f1cddd**: Fix uv not idempotent (close #3016)
- **d11ef2ad**: fix: sudo keepalive cleanup leaking exit code 143

### Theming
- **0974a606**: theming: kitty theme without terminal escape codes (#3086)
- **c85e98d6**: theming: material code: add antigravity
- **e72d39fe**: gtk theme: m3-ize more colors, fix distracting inactive fade

### Translations
- **a052a01e**: Updated the Russian language (#3089) - major update

## Files Changed

### Hyprland Config
- [dots/.config/hypr/hyprland.conf](dots/.config/hypr/hyprland.conf)
- [dots/.config/hypr/hyprland/env.conf](dots/.config/hypr/hyprland/env.conf)
- [dots/.config/hypr/hyprland/general.conf](dots/.config/hypr/hyprland/general.conf)
- [dots/.config/hypr/hyprland/keybinds.conf](dots/.config/hypr/hyprland/keybinds.conf)
- [dots/.config/hypr/hyprland/shellOverrides/main.conf](dots/.config/hypr/hyprland/shellOverrides/main.conf) (NEW)

### Quickshell Core
- [dots/.config/quickshell/ii/modules/common/Config.qml](dots/.config/quickshell/ii/modules/common/Config.qml)
- [dots/.config/quickshell/ii/modules/common/models/NestableObject.qml](dots/.config/quickshell/ii/modules/common/models/NestableObject.qml) (NEW)
- [dots/.config/quickshell/ii/modules/common/models/hyprland/HyprlandConfigOption.qml](dots/.config/quickshell/ii/modules/common/models/hyprland/HyprlandConfigOption.qml) (NEW)
- [dots/.config/quickshell/ii/modules/common/models/quickToggles/AntiFlashbangToggle.qml](dots/.config/quickshell/ii/modules/common/models/quickToggles/AntiFlashbangToggle.qml)
- [dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml](dots/.config/quickshell/ii/modules/common/models/quickToggles/GameModeToggle.qml)
- [dots/.config/quickshell/ii/modules/common/widgets/shapes](dots/.config/quickshell/ii/modules/common/widgets/shapes) (submodule)

### Quickshell UI Modules
- [dots/.config/quickshell/ii/modules/ii/background/widgets/clock/CookieClock.qml](dots/.config/quickshell/ii/modules/ii/background/widgets/clock/CookieClock.qml)
- [dots/.config/quickshell/ii/modules/ii/bar/Workspaces.qml](dots/.config/quickshell/ii/modules/ii/bar/Workspaces.qml)
- [dots/.config/quickshell/ii/modules/ii/dock/DockAppButton.qml](dots/.config/quickshell/ii/modules/ii/dock/DockAppButton.qml)
- [dots/.config/quickshell/ii/modules/ii/lock/Lock.qml](dots/.config/quickshell/ii/modules/ii/lock/Lock.qml)
- [dots/.config/quickshell/ii/modules/ii/mediaControls/PlayerControl.qml](dots/.config/quickshell/ii/modules/ii/mediaControls/PlayerControl.qml)
- [dots/.config/quickshell/ii/modules/ii/overlay/OverlayContext.qml](dots/.config/quickshell/ii/modules/ii/overlay/OverlayContext.qml)
- [dots/.config/quickshell/ii/modules/ii/overlay/OverlayTaskbar.qml](dots/.config/quickshell/ii/modules/ii/overlay/OverlayTaskbar.qml)
- [dots/.config/quickshell/ii/modules/ii/overlay/StyledOverlayWidget.qml](dots/.config/quickshell/ii/modules/ii/overlay/StyledOverlayWidget.qml)
- [dots/.config/quickshell/ii/modules/ii/overview/Overview.qml](dots/.config/quickshell/ii/modules/ii/overview/Overview.qml)
- [dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml](dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml)
- [dots/.config/quickshell/ii/modules/ii/sessionScreen/SessionScreen.qml](dots/.config/quickshell/ii/modules/ii/sessionScreen/SessionScreen.qml)
- [dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml](dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml)
- [dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRight.qml](dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRight.qml)
- [dots/.config/quickshell/ii/modules/ii/sidebarRight/nightLight/NightLightDialog.qml](dots/.config/quickshell/ii/modules/ii/sidebarRight/nightLight/NightLightDialog.qml)
- [dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelector.qml](dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelector.qml)
- [dots/.config/quickshell/ii/modules/settings/BackgroundConfig.qml](dots/.config/quickshell/ii/modules/settings/BackgroundConfig.qml)
- [dots/.config/quickshell/ii/modules/settings/ServicesConfig.qml](dots/.config/quickshell/ii/modules/settings/ServicesConfig.qml)

### Waffle Panel
- [dots/.config/quickshell/ii/modules/waffle/bar/tasks/TaskAppButton.qml](dots/.config/quickshell/ii/modules/waffle/bar/tasks/TaskAppButton.qml)
- [dots/.config/quickshell/ii/modules/waffle/notificationCenter/CalendarWidget.qml](dots/.config/quickshell/ii/modules/waffle/notificationCenter/CalendarWidget.qml)
- [dots/.config/quickshell/ii/modules/waffle/screenSnip/WRegionSelectionPanel.qml](dots/.config/quickshell/ii/modules/waffle/screenSnip/WRegionSelectionPanel.qml)

### Services
- [dots/.config/quickshell/ii/services/Ai.qml](dots/.config/quickshell/ii/services/Ai.qml)
- [dots/.config/quickshell/ii/services/GlobalFocusGrab.qml](dots/.config/quickshell/ii/services/GlobalFocusGrab.qml)
- [dots/.config/quickshell/ii/services/HyprlandAntiFlashbangShader.qml](dots/.config/quickshell/ii/services/HyprlandAntiFlashbangShader.qml) (NEW)
- [dots/.config/quickshell/ii/services/HyprlandConfig.qml](dots/.config/quickshell/ii/services/HyprlandConfig.qml) (NEW)
- [dots/.config/quickshell/ii/services/HyprlandData.qml](dots/.config/quickshell/ii/services/HyprlandData.qml)
- [dots/.config/quickshell/ii/services/MprisController.qml](dots/.config/quickshell/ii/services/MprisController.qml)
- [dots/.config/quickshell/ii/services/Network.qml](dots/.config/quickshell/ii/services/Network.qml)
- [dots/.config/quickshell/ii/services/SessionWarnings.qml](dots/.config/quickshell/ii/services/SessionWarnings.qml)
- [dots/.config/quickshell/ii/services/Updates.qml](dots/.config/quickshell/ii/services/Updates.qml)
- [dots/.config/quickshell/ii/services/hyprlandAntiFlashbangShader/anti-flashbang.glsl](dots/.config/quickshell/ii/services/hyprlandAntiFlashbangShader/anti-flashbang.glsl) (NEW)

### Scripts
- [dots/.config/quickshell/ii/scripts/colors/applycolor.sh](dots/.config/quickshell/ii/scripts/colors/applycolor.sh)
- [dots/.config/quickshell/ii/scripts/colors/code/material-code-set-color.sh](dots/.config/quickshell/ii/scripts/colors/code/material-code-set-color.sh)
- [dots/.config/quickshell/ii/scripts/colors/switchwall.sh](dots/.config/quickshell/ii/scripts/colors/switchwall.sh)
- [dots/.config/quickshell/ii/scripts/colors/terminal/kitty-theme.conf](dots/.config/quickshell/ii/scripts/colors/terminal/kitty-theme.conf) (NEW)
- [dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py](dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py) (NEW)
- [dots/.config/quickshell/ii/scripts/musicRecognition/recognize-music.sh](dots/.config/quickshell/ii/scripts/musicRecognition/recognize-music.sh)
- [dots/.config/quickshell/ii/scripts/thumbnails/generate-thumbnails-magick.sh](dots/.config/quickshell/ii/scripts/thumbnails/generate-thumbnails-magick.sh)

### Theming
- [dots/.config/kitty/kitty.conf](dots/.config/kitty/kitty.conf)
- [dots/.config/matugen/templates/gtk-3.0/gtk.css](dots/.config/matugen/templates/gtk-3.0/gtk.css)
- [dots/.config/matugen/templates/gtk-4.0/gtk.css](dots/.config/matugen/templates/gtk-4.0/gtk.css)

### Assets
- [dots/.config/quickshell/ii/assets/icons/fluent/ethernet-filled.svg](dots/.config/quickshell/ii/assets/icons/fluent/ethernet-filled.svg) (NEW)

### Translations
- [dots/.config/quickshell/ii/translations/ru_RU.json](dots/.config/quickshell/ii/translations/ru_RU.json)

### Other
- [dots/.config/fish/config.fish](dots/.config/fish/config.fish)

## Skipped (Fork-specific)

The following changes were included but relate to components this fork has modified/removed:
- **bda38341**, **36537150**, **b4b422bd**: AI sidebar extraModels loading - kept for structural compatibility
- **5ac58bdb**, **c19e6250**: Translator RTL fixes - kept as Translator.qml still exists in fork
- **5ab4812a**: gemini-categorize-wallpaper.sh upgrade - kept (optional feature)

## Setup Script Changes (Not Auto-Applied)

These changes affect `sdata/` and should be reviewed manually:
- `sdata/lib/functions.sh`: sudo keepalive cleanup fix (|| true)
- `sdata/lib/package-installers.sh`: uv venv uses `try` for idempotency
- `sdata/dist-arch/illogical-impulse-quickshell-git/PKGBUILD`: new pinned commit, vulkan-headers dep
- `sdata/dist-gentoo/*`: various updates
