# Fork Exclusions — Files that DO NOT exist in this fork

These files are intentionally removed from this fork (AI Chat, Anime/Booru browser, Translator). They must NEVER be synced from upstream or included in apply scripts.

---

## AI Components

- `dots/.config/quickshell/ii/services/Ai.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/AiChat.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/aiChat/`
- `dots/.config/quickshell/ii/scripts/ai/`
- `dots/.config/quickshell/ii/defaults/ai/` (AI prompts)
- `dots/.config/quickshell/ii/assets/icons/ollama-symbolic.svg`
- `dots/.config/quickshell/ii/assets/icons/openai-symbolic.svg`
- `dots/.config/quickshell/ii/assets/icons/ai-openai-symbolic.svg`
- `dots/.config/quickshell/ii/assets/icons/google-gemini-symbolic.svg`

## Anime / Booru Components

- `dots/.config/quickshell/ii/services/Booru.qml`
- `dots/.config/quickshell/ii/services/BooruResponseData.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/Anime.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/anime/`

## Translator Components

- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/Translator.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/translator/`

---

## Fork-Modified Files — Require MANUAL MERGE (do not blindly copy)

These files exist in the fork but have manual modifications that remove the AI/Anime/Translator features. When upstream changes these files, manually port upstream changes while keeping the removed features excluded.

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeftContent.qml`
  - Fork removes: AiChat, Anime, Translator tab entries (approximately lines ~97–105)

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/ii/bar/LeftSidebarButton.qml`
  - Fork removes: `Booru.downloadingImages` badge (approximately line ~41)

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/common/Config.qml`
  - Fork removes: `policies` (ai, weeb), `ai` config block, `sidebar.translator`, `sidebar.booru`, `sidebar.ai`, `background.widgets.clock.cookie.aiStyling`

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/common/Directories.qml`
  - Fork removes: `booruPreviews`, `booruDownloads`, `booruDownloadsNsfw`, `defaultAiPrompts`, `userAiPrompts`, `aiChats`, `aiTranslationScriptPath` properties and related Component.onCompleted code

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/common/Persistent.qml`
  - Fork removes: `ai` and `booru` persistent state objects

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/settings/ServicesConfig.qml`
  - Fork removes: AI section with system prompt config

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/settings/GeneralConfig.qml`
  - Fork removes: translationProc Process, Gemini translation section, Policies section (AI/Weeb)

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/settings/InterfaceConfig.qml`
  - Fork removes: translator toggle

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/settings/QuickConfig.qml`
  - Fork removes: Random Konachan and osu! wallpaper buttons

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/settings/BackgroundConfig.qml`
  - Fork removes: Gemini auto-styling switch for cookie clock

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelectorContent.qml`
  - Fork removes: "Homework" directory entry conditioned on weeb policy

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/modules/ii/background/widgets/clock/CookieClock.qml`
  - Fork removes: aiStyling feature (setClockPreset returns early)

- **MANUAL_MERGE:** `dots/.config/quickshell/ii/welcome.qml`
  - Fork removes: konachanWallProc, translationProc, Gemini translation section, Random Konachan button, Policies section

---

Keep this file up-to-date with any other files explicitly removed from the fork.
