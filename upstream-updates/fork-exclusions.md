# Fork Exclusions — Files that DO NOT exist in this fork

These files are intentionally removed from this fork (AI Chat, Anime/Booru browser, Translator). They must NEVER be synced from upstream or included in apply scripts.

---

## AI Components

- `dots/.config/quickshell/ii/services/Ai.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/AiChat.qml`
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/aiChat/`
- `dots/.config/quickshell/ii/scripts/ai/`

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

---

Keep this file up-to-date with any other files explicitly removed from the fork.
