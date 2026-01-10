# Changelog: Upstream merge (2b4664671..60fd1ea03)

This file lists each upstream commit that was merged into this branch
Entries are in chronological order (oldest → newest).

Commit range:

- from : 2b4664671
- to : 60fd1ea03

- **c5c8ad223** (2026-01-01): lock screen: unfuck resolution

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/lock/Lock.qml](dots/.config/quickshell/ii/modules/ii/lock/Lock.qml)

- **af1adef5f** (2026-01-01): make date not misaligned for vertical digital clock

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/background/widgets/clock/ClockWidget.qml](dots/.config/quickshell/ii/modules/ii/background/widgets/clock/ClockWidget.qml)
    - [dots/.config/quickshell/ii/modules/ii/background/widgets/clock/DigitalClock.qml](dots/.config/quickshell/ii/modules/ii/background/widgets/clock/DigitalClock.qml)

- **575b26d57** (2026-01-01): make overview show only on focused monitor (fixes #2782)

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/overview/Overview.qml](dots/.config/quickshell/ii/modules/ii/overview/Overview.qml)
    - [dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml](dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml)

- **199845bf5** (2026-01-01): update shapes submodule

  - Files changed:
    - [dots/.config/quickshell/ii/modules/common/widgets/shapes](dots/.config/quickshell/ii/modules/common/widgets/shapes)

- **e818a202b** (2026-01-01): overview: fix clipboard and emoji keybinds

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/overview/Overview.qml](dots/.config/quickshell/ii/modules/ii/overview/Overview.qml)

- **171cf6059** (2026-01-01): Update shapes

  - Files changed:
    - [dots/.config/quickshell/ii/modules/common/widgets/shapes](dots/.config/quickshell/ii/modules/common/widgets/shapes)

- **5a687c356** (2026-01-01): fix persisting Windows key, instead of user configured key

  - Files changed:
    - [dots/.config/quickshell/ii/modules/settings/QuickConfig.qml](dots/.config/quickshell/ii/modules/settings/QuickConfig.qml)

- **7238b2b15** (2026-01-01): use shared focusgrab for most stuff (makes osk usable w/ other panels)

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/bar/Bar.qml](dots/.config/quickshell/ii/modules/ii/bar/Bar.qml)
    - [dots/.config/quickshell/ii/modules/ii/cheatsheet/Cheatsheet.qml](dots/.config/quickshell/ii/modules/ii/cheatsheet/Cheatsheet.qml)
    - [dots/.config/quickshell/ii/modules/ii/mediaControls/MediaControls.qml](dots/.config/quickshell/ii/modules/ii/mediaControls/MediaControls.qml)
    - [dots/.config/quickshell/ii/modules/ii/onScreenKeyboard/OnScreenKeyboard.qml](dots/.config/quickshell/ii/modules/ii/onScreenKeyboard/OnScreenKeyboard.qml)
    - [dots/.config/quickshell/ii/modules/ii/overview/Overview.qml](dots/.config/quickshell/ii/modules/ii/overview/Overview.qml)
    - [dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml](dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml)
    - [dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRight.qml](dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRight.qml)
    - [dots/.config/quickshell/ii/modules/ii/verticalBar/VerticalBar.qml](dots/.config/quickshell/ii/modules/ii/verticalBar/VerticalBar.qml)
    - [dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelector.qml](dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelector.qml)
    - [dots/.config/quickshell/ii/services/GlobalFocusGrab.qml](dots/.config/quickshell/ii/services/GlobalFocusGrab.qml) (new)

- **c9d0248a6** (2026-01-01): Fix missing v in 3.files.sh (#2792)

  - Files changed:
    - [sdata/subcmd-install/3.files.sh](sdata/subcmd-install/3.files.sh)

- **d5b599da3** (2026-01-01): overview: limit search results while typing (less laggy emoji/clipboard search)

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/overview/SearchWidget.qml](dots/.config/quickshell/ii/modules/ii/overview/SearchWidget.qml)

- **da578735e** (2026-01-03): fix: update changePassword function to use SSID variable for network modification

  - Files changed:
    - [dots/.config/quickshell/ii/services/Network.qml](dots/.config/quickshell/ii/services/Network.qml)

- **dc57f940d** (2026-01-03): Fix when wifi having space in between (#2812)

  - Files changed: (no files listed in this merge range)

- **711793dd6** (2026-01-03): FIX: Quick Settings keybinding hint (#2794)

  - Files changed: (no files listed in this merge range)

- **b268f1d61** (2026-01-03): add missing comma

  - Files changed:
    - [dots/.config/quickshell/ii/services/Network.qml](dots/.config/quickshell/ii/services/Network.qml)

- **8538efe74** (2026-01-04): overview: tab to copy selected result

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/overview/SearchBar.qml](dots/.config/quickshell/ii/modules/ii/overview/SearchBar.qml)
    - [dots/.config/quickshell/ii/modules/ii/overview/SearchWidget.qml](dots/.config/quickshell/ii/modules/ii/overview/SearchWidget.qml)

- **58e372c59** (2026-01-03): Fixed issue where thumbgenProc would not fallback on generate-thumbnails-magick.sh if thumbgen-venv.sh fails. Fixed issue where thumbnails would not reload after being generated.

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperDirectoryItem.qml](dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperDirectoryItem.qml)
    - [dots/.config/quickshell/ii/scripts/thumbnails/thumbgen-venv.sh](dots/.config/quickshell/ii/scripts/thumbnails/thumbgen-venv.sh)

- **7197f9ddf** (2026-01-03): add last refresh timestamp to weather popup

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/bar/weather/WeatherPopup.qml](dots/.config/quickshell/ii/modules/ii/bar/weather/WeatherPopup.qml)
    - [dots/.config/quickshell/ii/services/Weather.qml](dots/.config/quickshell/ii/services/Weather.qml)

- **14c930d48** (2026-01-03): Use wrapper functions in DateTime to format

  - Files changed:
    - [dots/.config/quickshell/ii/services/Weather.qml](dots/.config/quickshell/ii/services/Weather.qml)

- **22970db52** (2026-01-04): Fix: Wallpaper selector missing previews (#2818)

  - Files changed: (no files listed in this merge range)

- **bf06497f9** (2026-01-04): weatherpopup: remove useless layouts

  - Files changed:
    - [dots/.config/quickshell/ii/modules/ii/bar/weather/WeatherPopup.qml](dots/.config/quickshell/ii/modules/ii/bar/weather/WeatherPopup.qml)

- **60fd1ea03** (2026-01-04): feat: add last refresh timestamp to weather popup (#2819)
  - Files changed: (merge tip)

---

Generated from git range `2b4664671..60fd1ea03` on 2026-01-08.
