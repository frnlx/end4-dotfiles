# Upstream Sync bundle

**Commit range:** `c0706258` → `42d0aae1`
**Date range:** 2026-05-16 to 2026-08-15

### Summary

This update brings significant improvements to the Quickshell workspace bar and component architecture, dispatcher compatibility fixes for Hyprland Lua configuration, theme/wallpaper variant switching, and support for additional distributions and init systems (`dinit`).

**Highlights:**
- **Quickshell Workspaces Overhaul:** Complete rewrite of `Workspaces.qml` utilizing `WorkspaceModel.qml`, smooth trailing indicator transitions, super-key press-and-hold timer, and middle/back mouse button shortcuts for special workspace toggling.
- **Component Library Expansions:** Added new reusable QML building blocks including `Box.qml`, `BoxLayout.qml`, `AppIcon.qml`, `ButtonMouseArea.qml`, `Colorizer.qml`, `Pill.qml`, `StateLayer.qml`, `StateOverlay.qml`, `StyledRectangle.qml`, and `NumberUtils.qml`.
- **Qt 6.11 Notification Freeze Fix:** Fixed infinite `polish()` loop on `NotificationItem.qml` under Qt 6.11.
- **Hyprland & Dispatcher Fixes:** `hypridle.conf` updated to use Lua dispatcher format (`hl.dsp.global` and `hl.dsp.dpms`); `hyprland.lua` safely checks file existence before requiring `workspaces.lua` and `monitors.lua` (nwg-displays).
- **Anti-Flashbang Cycling:** Added weak shader variant (`anti-flashbang-weak.glsl`) and 3-way toggle (Off → Weak → Strong).
- **Theme & Wallpaper Enhancements:** Automatic `-dark` and `-light` variant switching based on file suffix in `switchwall.sh`.
- **Distro & Init Support:** Added Manjaro distro icon support and `dinit` init system support across installation and service management scripts.
- **MicroTeX PKGBUILD Update:** Migrated MicroTeX upstream repository to `end-4/MicroTeX`.

### Important notes for this fork

- **Excluded from sync** (AI / Anime / Booru / Translator components):
  - `dots/.config/quickshell/ii/modules/ii/sidebarLeft/anime/BooruImage.qml`
  - `dots/.config/quickshell/ii/modules/ii/sidebarLeft/anime/BooruResponse.qml`
  - `dots/.config/quickshell/ii/scripts/colors/random/random_konachan_wall.sh`
  - `dots/.config/quickshell/ii/services/Booru.qml`

- **Preserved Fork Customizations:**
  - `ResourceUsage.qml` & `ResourcesPopup.qml` CPU temperature reading.
  - Custom shapes and terminal themes.

---

### Commits (chronological)

- **d24cbff7** (2026-04-14): fix(ii): send user agent for Konachan wallpaper
- **36e0c3fd** (2026-04-14): fix(ii): remove Konachan wallpaper UA fallback
- **14f8b846** (2026-04-14): fix(ii): add Konachan support in sidebar
- **329fa312** (2026-04-15): Fix broken waifu.im image and tag search
- **4eef9ea1** (2026-04-21): Fix still tags not being applied to search request.
- **403f7aa6** (2026-05-12): fix: show escaped text for selected entry in clipboard
- **b85ed869** (2026-05-12): Fix monitor scale type
- **d4d78a5e** (2026-05-17): fix(hyprsunset): remove vestigial Hyprland.dispatch broken under .lua schema
- **d4e77791** (2026-05-17): Fix: XDG_DATA_DIRS now expands correctly
- **b470bf3f** (2026-05-18): Fix: XDG_DATA_DIRS now expands correctly (fixes 3354) (#3358)
- **c1b37bc4** (2026-05-18): fix(hyprsunset): remove vestigial Hyprland.dispatch broken under .lua schema (#3356)
- **25fe0ab0** (2026-05-20): fix(hyprland): restore nwg-display entry
- **20d1ff06** (2026-05-20): style: space indent
- **8f9cf67b** (2026-05-21): fix(screenCorners): remove shadowing screen property to fix multi-monitor corner rendering
- **6eaa869f** (2026-05-21): fix(qs): NotificationItem polish() loop on Qt 6.11
- **ce809512** (2026-05-22): fix: hypridle dispatch commands for Lua-based Hyprland
- **b9e05599** (2026-05-24): Fix screen corners only appearing on integrated monitor (#3386)
- **9c115f7a** (2026-05-24): fix: hypridle Lua-dispatch compatibility for lock and DPMS (#3393)
- **c58bb07a** (2026-05-24): fix(qs): NotificationItem polish() loop on Qt 6.11 — freezes sidebar (#3388)
- **54a1d172** (2026-05-24): add file existence check for nwg displays include
- **a56cee16** (2026-05-24): Restore nwg-displays entry (#3381)
- **091da11d** (2026-05-24): Fix monitor scale type (#3312)
- **eb3613d3** (2026-05-24): fix: show escaped text for selected entry in clipboard (#3303)
- **9b149e6f** (2026-05-24): qs: sidebar: quick toggle: friendlier/shorter default state text
- **a15f2a8a** (2026-05-24): add a weak anti flashbang variant
- **aa044b45** (2026-05-24): fix source url safe access
- **397fb8d8** (2026-05-24): Fix broken waifu.im image and tag search (#3239)
- **14376cec** (2026-05-24): fix(ii): send configured User-Agent to Konachan requests  (#3232)
- **6eb590b1** (2026-05-25): add light/dark wallpaper variant switching based on suffix
- **e0f2a349** (2026-05-27): Wrong dpms syntax
- **f5b2b754** (2026-05-26): Fix wrong dpms syntax (#3407)
- **3cb611c0** (2026-05-29): No more sleep 0
- **d619ddcd** (2026-06-05): not use raw keycode binds for super+alt+ws (fixes #3368)
- **0bfade5c** (2026-06-05): Fix microtex build failure (#3422)
- **d192a25f** (2026-06-05): Merge remote-tracking branch 'refs/remotes/origin/main'
- **975a261f** (2026-06-13): change microtex repo to end4's repo
- **c04b0bbc** (2026-06-14): gentoo microtex update (#3456)
- **deb9a99c** (2026-07-15): Fix broken ls command
- **446504ad** (2026-07-16): bar: workspaces from hefty
- **3fe17163** (2026-07-20): fedora: add quickshell deps to feddeps.toml
- **0497cf53** (2026-07-21): fedora: add quickshell deps to feddeps.toml (#3530)
- **7e61a6a5** (2026-07-21): Fix broken ls command (#3513)
- **80c884cc** (2026-07-22): feat(quickshell): add Manjaro distro icon support
- **1a9ffb78** (2026-07-25): bar: workspaces: back mouse button to toggle special
- **aed4d1ec** (2026-07-27): feat(sidebar): add Manjaro distro icon support (#3536)
- **69f1a543** (2026-08-11): konsole: ctrl c for copy
- **3e3be07b** (2026-08-12): feat(install): add dinit init system support
- **24326070** (2026-08-12): fix: ydtool config fix being wrong bruh
- **de4ed0f5** (2026-08-12): fix: add missing power profile daemon dinit component :/
- **805a2aaf** (2026-08-14): Fix: error when service already enabled (final push  🙏)
- **42d0aae1** (2026-08-15): feat(install): add dinit init system support (#3584)

---

### Files changed

**New files:**
- `dots/.config/quickshell/ii/assets/icons/manjaro-symbolic.svg`
- `dots/.config/quickshell/ii/modules/common/functions/NumberUtils.qml`
- `dots/.config/quickshell/ii/modules/common/models/WorkspaceModel.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/AppIcon.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/Box.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/BoxLayout.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/ButtonMouseArea.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/Colorizer.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/Pill.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/StateLayer.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/StateOverlay.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/StyledRectangle.qml`
- `dots/.config/quickshell/ii/services/hyprlandAntiFlashbangShader/anti-flashbang-weak.glsl`
- `dots/.local/share/kxmlgui5/konsole/sessionui.rc`

**Modified files:**
- `dots/.config/fish/config.fish`
- `dots/.config/hypr/hypridle.conf`
- `dots/.config/hypr/hyprland.lua`
- `dots/.config/hypr/hyprland/env.lua`
- `dots/.config/hypr/hyprland/general.lua`
- `dots/.config/hypr/hyprland/keybinds.lua`
- `dots/.config/quickshell/ii/modules/common/models/quickToggles/AntiFlashbangToggle.qml`
- `dots/.config/quickshell/ii/modules/common/utils/ImageDownloaderProcess.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/NotificationItem.qml`
- `dots/.config/quickshell/ii/modules/ii/bar/Workspaces.qml`
- `dots/.config/quickshell/ii/modules/ii/overview/SearchItem.qml`
- `dots/.config/quickshell/ii/modules/ii/screenCorners/ScreenCorners.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarRight/quickToggles/androidStyle/AndroidQuickToggleButton.qml`
- `dots/.config/quickshell/ii/scripts/colors/switchwall.sh`
- `dots/.config/quickshell/ii/services/HyprlandAntiFlashbangShader.qml`
- `dots/.config/quickshell/ii/services/Hyprsunset.qml`
- `dots/.config/quickshell/ii/services/SystemInfo.qml`
- `sdata/dist-arch/illogical-impulse-microtex-git/PKGBUILD`
- `sdata/dist-arch/install-deps.sh`
- `sdata/dist-fedora/feddeps.toml`
- `sdata/dist-fedora/install-deps.sh`
- `sdata/dist-gentoo/illogical-impulse-microtex-git/illogical-impulse-microtex-git-1.0-r2.ebuild`
- `sdata/lib/dist-determine.sh`
- `sdata/lib/functions.sh`
- `sdata/subcmd-install/0.greeting.sh`
- `sdata/subcmd-install/1.deps-router.sh`
- `sdata/subcmd-install/2.setups.sh`
- `sdata/subcmd-install/3.files-exp.sh`
- `sdata/subcmd-install/3.files-legacy.sh`
