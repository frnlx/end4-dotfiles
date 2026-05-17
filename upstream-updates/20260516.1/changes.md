# Upstream Sync bundle

**Commit range:** `47235ac4` → `c0706258`
**Date range:** 2026-05-01 to 2026-05-16

### Summary

This is a **major update** featuring the migration of Hyprland configuration from `.conf` files to `.lua` files. The new lua-based config provides better modularity, custom config auto-creation, and improved keybind categorization.

**Highlights:**
- Hyprland config fully migrated to Lua (hyprland.lua + hyprland/*.lua + custom/*.lua)
- Cheatsheet now displays keybind categories nicely
- Super key hold state fixes
- Notification force-monitor option added
- Hyprsunset default color temperature fixed (6000K)
- Emoji list updated to emoji 17.0
- Kitty config fixes
- Proper image scaling with screen scaling
- Fedora deps reworked (uses prebuilt RPMs)
- Removed: kvantum color scripts, old get_keybinds.py, workspace_action.sh, zoom.sh

### Important notes for this fork

- **Excluded from sync** (AI/Anime/Translator components):
  - `dots/.config/quickshell/ii/modules/ii/screenTranslator/ScreenTextOverlay.qml`
  - `dots/.config/quickshell/ii/modules/ii/sidebarLeft/anime/BooruImage.qml`

- **Hyprland config migration:** Old `.conf` files in `~/.config/hypr/hyprland/` are backed up and removed. `~/.config/hypr/hyprland.conf` is backed up and replaced with `hyprland.lua`. Custom `.conf` files in `~/.config/hypr/custom/` are left in place for reference but will not be loaded.

---

### Commits (chronological)

- **72d950ed** (2026-04-25): change hyprsunset default color temp to 6000
- **fe9eb0e8** (2026-05-01): add class selectors to nautilus pathbar elements
- **242de398** (2026-05-02): add linunwind-devel to dependencies for cpptrace
- **ffabb856** (2026-05-02): feat: update emoji list to emoji 17.0
- **54e19afa** (2026-05-02): Add files via upload
- **cec16c87** (2026-05-02): Create main.lua
- **7834f222** (2026-05-02): Add files via upload
- **0e1f6a97** (2026-05-02): Create env.lua
- **aff62069** (2026-05-02): Create execs.lua
- **b034a712** (2026-05-02): Create general.lua
- **2cfb0c27** (2026-05-02): Create keybinds.lua
- **c0888cbb** (2026-05-02): Create rules.lua
- **c693a3f5** (2026-05-02): Create variables.lua
- **36a4a19b** (2026-05-03): Add files via upload
- **63495d0b** (2026-05-03): Add files via upload
- **d1cd892c** (2026-05-03): Add files via upload
- **c652d2a7** (2026-05-04): Update gtk-4 styles for recent changes (#3266)
- **f992294e** (2026-05-04): proper image scaling with screen scaling (#3036, #3037)
- **e7c283e9** (2026-05-04): fix terminal theming
- **84cd4582** (2026-05-05): install every package right after building
- **5c69271c** (2026-05-05): fedora: Install packages right after building (#3273)
- **fb3ec1fd** (2026-05-06): Add files via upload
- **c3147dc7** (2026-05-07): Add files via upload
- **0ae90051** (2026-05-07): Add files via upload
- **74c10b91** (2026-05-07): fix kitty config
- **bfad75c9** (2026-05-08): Fix quickshell PKGBUILD to work with some packages (fix #3286)
- **c67c8840** (2026-05-08): rewrite script to use RPM built using GitHub action
- **adb36f43** (2026-05-08): replace tested note
- **bebf66da** (2026-05-09): Use packages from end-4/ii-package-builds for fedora (#3288)
- **0da83ba4** (2026-05-09): feat: notification on specific monitor
- **f6b97c46** (2026-05-09): Update general.lua
- **010f070e** (2026-05-11): fix stuff
- **9f4afde0** (2026-05-11): use globalshortcut for 4finger up touchpad gesture
- **6c041b95** (2026-05-11): migrate hyprland config to lua (#3269)
- **760c7034** (2026-05-11): qs: fix hyprland dispatchers
- **e11d084b** (2026-05-11): remove redundant wallpaper switching stuff
- **2e161911** (2026-05-12): qs: fix hyprland overrides (game mode, anti flashbang)
- **7dcbabcd** (2026-05-12): fix screen locking
- **807c761e** (2026-05-12): qs: fix some manual hyprland dispatches
- **ae7f6bd1** (2026-05-12): fix keybind cheatsheet
- **388783e9** (2026-05-12): hyprland: exclude monitors and workspaces conf
- **281b3e56** (2026-05-12): previous commit but in the "legacy" script
- **a9f87c06** (2026-05-12): install script: rename hyprland.conf to not use it
- **7aad60eb** (2026-05-12): install script: add check for hyprland.conf rename
- **1c117e08** (2026-05-12): add example keybind for editing user keybinds
- **ba0e76da** (2026-05-12): fix hyprland theming
- **20dde159** (2026-05-12): readme: add hyprland 0.55 warning
- **1e442f1a** (2026-05-12): qs: temp fix super key always thought to be held down
- **c53e9891** (2026-05-12): qs: fix super key hold state properly
- **d6b27cf9** (2026-05-12): fix(keybinds): correct fullscreen and maximize bind syntax
- **412b2222** (2026-05-12): readme: move warning content to wiki
- **ac8d0e9a** (2026-05-12): fix: specify toggle action explicitly
- **e8721b4b** (2026-05-13): Fix HOME env in lua
- **f7773aca** (2026-05-13): Do not override XDG_DATA_DIRS (fixes #2583)
- **5ce6280d** (2026-05-13): fix(keybinds): correct fullscreen and maximize bind syntax (#3306)
- **737eb7c3** (2026-05-13): Do not override XDG_DATA_DIRS (fixes #2583) (#3321)
- **e6d2a7d8** (2026-05-13): Fix HOME env in lua (#3316)
- **c504cdf2** (2026-05-13): Fix kitty config (#3284)
- **00a4235a** (2026-05-13): Update emoji list to emoji 17.0 (#3268)
- **b7b2e6e1** (2026-05-13): fix Hyprsunset default color temperature (#3254)
- **9e1568fc** (2026-05-13): qs: rename config option notifications.monitor to notifications.forceMonitor
- **ad12fe6d** (2026-05-13): feat: notification on specific monitor (#3292)
- **08201f2a** (2026-05-14): hl: keybinds: fix workspace groups, categorize descriptions
- **2ade168a** (2026-05-14): hl config: remove unused bash scripts
- **d1daedc6** (2026-05-14): qs: cheatsheet: display categories nicely
- **239b532e** (2026-05-14): ctrl+super+shift+d for dark/light toggle (like powertoys)
- **c5326575** (2026-05-14): hl: create custom config files automatically
- **7d5ce9a7** (2026-05-14): hl: fix #3327 send to scratchpad desc at wrong scope
- **798d35a5** (2026-05-14): hl: remove that whatever jetbrains windowrule (fixes #3324)
- **28ba8a4f** (2026-05-14): hl: make custom stuff optional
- **5c669029** (2026-05-14): qs: fix wrong capitalization in cheatsheet
- **d5f9afe7** (2026-05-14): qs: remove no longer necessary unlock refocus hack
- **9eda5017** (2026-05-14): remove redundant scripts
- **215ac747** (2026-05-15): Update keybinds.lua
- **68c67ace** (2026-05-14): Update keybinds.lua to allow hl.unbind() (#3336)
- **c0706258** (2026-05-16): add back some repetitive keybinds to cheatsheet

---

### Files changed

**New files (Lua Hyprland config):**
- `dots/.config/hypr/custom/env.lua`
- `dots/.config/hypr/custom/execs.lua`
- `dots/.config/hypr/custom/general.lua`
- `dots/.config/hypr/custom/keybinds.lua`
- `dots/.config/hypr/custom/rules.lua`
- `dots/.config/hypr/custom/variables.lua`
- `dots/.config/hypr/hyprland.lua`
- `dots/.config/hypr/hyprland/colors.lua`
- `dots/.config/hypr/hyprland/env.lua`
- `dots/.config/hypr/hyprland/execs.lua`
- `dots/.config/hypr/hyprland/general.lua`
- `dots/.config/hypr/hyprland/keybinds.lua`
- `dots/.config/hypr/hyprland/lib/init.lua`
- `dots/.config/hypr/hyprland/rules.lua`
- `dots/.config/hypr/hyprland/services/create_custom_config.lua`
- `dots/.config/hypr/hyprland/services/init.lua`
- `dots/.config/hypr/hyprland/shellOverrides/main.lua`
- `dots/.config/hypr/hyprland/variables.lua`
- `dots/.config/matugen/templates/hyprland/colors.lua`
- `dots/.config/quickshell/ii/modules/ii/cheatsheet/CheatsheetKeybindsCategory.qml`

**Modified files:**
- `dots/.config/hypr/hypridle.conf`
- `dots/.config/hypr/hyprland/scripts/fuzzel-emoji.sh`
- `dots/.config/matugen/config.toml`
- `dots/.config/matugen/templates/gtk-4.0/gtk.css`
- `dots/.config/quickshell/ii/modules/common/Config.qml`
- `dots/.config/quickshell/ii/modules/common/panels/lock/LockScreen.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/CliphistImage.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/DirectoryIcon.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/NotificationAppIcon.qml`
- `dots/.config/quickshell/ii/modules/common/widgets/StyledImage.qml`
- `dots/.config/quickshell/ii/modules/ii/background/Background.qml`
- `dots/.config/quickshell/ii/modules/ii/bar/UtilButtons.qml`
- `dots/.config/quickshell/ii/modules/ii/bar/Workspaces.qml`
- `dots/.config/quickshell/ii/modules/ii/cheatsheet/Cheatsheet.qml`
- `dots/.config/quickshell/ii/modules/ii/cheatsheet/CheatsheetKeybinds.qml`
- `dots/.config/quickshell/ii/modules/ii/lock/Lock.qml`
- `dots/.config/quickshell/ii/modules/ii/mediaControls/PlayerControl.qml`
- `dots/.config/quickshell/ii/modules/ii/notificationPopup/NotificationPopup.qml`
- `dots/.config/quickshell/ii/modules/ii/overlay/floatingImage/FloatingImage.qml`
- `dots/.config/quickshell/ii/modules/ii/overview/Overview.qml`
- `dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml`
- `dots/.config/quickshell/ii/modules/ii/overview/OverviewWindow.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRightContent.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarRight/volumeMixer/VolumeMixerEntry.qml`
- `dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperDirectoryItem.qml`
- `dots/.config/quickshell/ii/modules/settings/InterfaceConfig.qml`
- `dots/.config/quickshell/ii/modules/settings/QuickConfig.qml`
- `dots/.config/quickshell/ii/modules/waffle/lock/WaffleLock.qml`
- `dots/.config/quickshell/ii/modules/waffle/notificationCenter/WSingleNotification.qml`
- `dots/.config/quickshell/ii/modules/waffle/taskView/TaskViewContent.qml`
- `dots/.config/quickshell/ii/modules/waffle/taskView/TaskViewWindow.qml`
- `dots/.config/quickshell/ii/modules/waffle/taskView/TaskViewWorkspace.qml`
- `dots/.config/quickshell/ii/scripts/colors/applycolor.sh`
- `dots/.config/quickshell/ii/scripts/colors/code/material-code-set-color.sh`
- `dots/.config/quickshell/ii/scripts/colors/switchwall.sh`
- `dots/.config/quickshell/ii/scripts/colors/terminal/kitty-theme.conf`
- `dots/.config/quickshell/ii/scripts/hyprland/hyprconfigurator.py`
- `dots/.config/quickshell/ii/services/HyprlandConfig.qml`
- `dots/.config/quickshell/ii/services/HyprlandKeybinds.qml`
- `dots/.config/quickshell/ii/services/Hyprsunset.qml`
- `dots/.config/quickshell/ii/services/LauncherSearch.qml`
- `dots/.config/quickshell/ii/services/MaterialThemeLoader.qml`
- `dots/.config/quickshell/ii/services/Wallpapers.qml`
- `dots/.config/quickshell/ii/services/hyprlandAntiFlashbangShader/anti-flashbang.glsl`
- `sdata/dist-arch/illogical-impulse-quickshell-git/PKGBUILD`
- `sdata/dist-fedora/README.md`
- `sdata/dist-fedora/feddeps.toml`
- `sdata/dist-fedora/install-deps.sh`
- `sdata/subcmd-install/3.files-exp.yaml`
- `sdata/subcmd-install/3.files-legacy.sh`

**Removed upstream (backed up and deleted from $HOME):**
- `dots/.config/hypr/hyprland.conf`
- `dots/.config/hypr/hyprland/colors.conf`
- `dots/.config/hypr/hyprland/env.conf`
- `dots/.config/hypr/hyprland/execs.conf`
- `dots/.config/hypr/hyprland/general.conf`
- `dots/.config/hypr/hyprland/keybinds.conf`
- `dots/.config/hypr/hyprland/rules.conf`
- `dots/.config/hypr/hyprland/variables.conf`
- `dots/.config/hypr/hyprland/scripts/workspace_action.sh`
- `dots/.config/hypr/hyprland/scripts/zoom.sh`
- `dots/.config/hypr/hyprland/shellOverrides/main.conf`
- `dots/.config/matugen/templates/hyprland/colors.conf`
- `dots/.config/quickshell/ii/scripts/hyprland/get_keybinds.py`
- `dots/.config/quickshell/ii/scripts/kvantum/adwsvg.py`
- `dots/.config/quickshell/ii/scripts/kvantum/adwsvgDark.py`
- `dots/.config/quickshell/ii/scripts/kvantum/changeAdwColors.py`
- `dots/.config/quickshell/ii/scripts/kvantum/materialQT.sh`
