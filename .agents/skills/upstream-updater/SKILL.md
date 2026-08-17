---
name: upstream-updater
description: >-
  Use this skill when synchronizing changes from upstream `dots-hyprland` to this personalized
  `end4-dotfiles` fork, creating new `upstream-updates/YYYYMMDD.n` bundles, auditing pacman system updates,
  or resolving Quickshell / Hyprland update and reload issues.
---

# Upstream Updater Skill: `end4-dotfiles`

This skill provides the standard runbook and automation workflow for synchronizing changes from upstream (`/home/frnlx/end4files/dots-hyprland`) into this personalized dotfiles fork (`/home/frnlx/end4files/end4-dotfiles`).

---

## 1. Repository Architecture & Layout

- **Fork Root**: `/home/frnlx/end4files/end4-dotfiles` (branch `personalized`).
- **Upstream Clone**: `/home/frnlx/end4files/dots-hyprland` (branch `main`, remote `origin`).
- **Update Bundles**: `upstream-updates/YYYYMMDD.n/` where:
  - `YYYYMMDD` is the date of the last merged commit.
  - `.n` is the sequence counter (e.g. `.1`, `.2`).
  - Contains: `changes.md`, `apply-changes.sh`, and `restore-backup.sh`.
- **Fork Exclusions Reference**: [fork-exclusions.md](../../../upstream-updates/fork-exclusions.md).

---

## 2. ⚠️ Critical Rules & Fork Exclusions

### Never Sync Excluded Components
This fork permanently strips out AI Chat, Anime / Booru browsers, and Translator features:
- `dots/.config/quickshell/ii/services/Ai.qml`, `AiChat.qml`, `aiChat/`, `scripts/ai/`, prompts, and AI symbolic icons.
- `dots/.config/quickshell/ii/services/Booru.qml`, `BooruResponseData.qml`, `Anime.qml`, `anime/`, `random_konachan_wall.sh`.
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/Translator.qml`, `translator/`, `screenTranslator/`.

### Fork-Modified Files (Require Manual Merge)
When upstream touches any of the following, port features manually without re-introducing excluded components:
- `dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeftContent.qml`
- `dots/.config/quickshell/ii/modules/ii/bar/LeftSidebarButton.qml`
- `dots/.config/quickshell/ii/modules/common/Config.qml`
- `dots/.config/quickshell/ii/modules/common/Directories.qml`
- `dots/.config/quickshell/ii/modules/common/Persistent.qml`
- `dots/.config/quickshell/ii/modules/settings/*.qml` (Services, General, Interface, Quick, Background)
- `dots/.config/quickshell/ii/welcome.qml`

### Preserved Fork Features
- **CPU Temperature Sensor**: In `dots/.config/quickshell/ii/services/ResourceUsage.qml` and `dots/.config/quickshell/ii/modules/ii/bar/ResourcesPopup.qml`.
- **Custom Shapes & Themes**: In `dots/.config/quickshell/ii/modules/common/widgets/shapes` and `dots/.config/quickshell/ii/scripts/colors/set-kitty-theme.sh`.

---

## 3. Step-by-Step Update Workflow

### Step 1: Inspect Upstream Diff & Commits
Run the helper script to identify new commits, changed files, and flag any excluded files:
```bash
.agents/skills/upstream-updater/scripts/check-upstream-diff.sh
```

Or manually:
```bash
git -C /home/frnlx/end4files/dots-hyprland fetch origin main
git -C /home/frnlx/end4files/dots-hyprland log --reverse --format="- **%h** (%ad): %s" --date=short <LAST_COMMIT>..origin/main
git -C /home/frnlx/end4files/dots-hyprland diff --name-status <LAST_COMMIT> origin/main
```

Fast-forward upstream repository once verified:
```bash
git -C /home/frnlx/end4files/dots-hyprland pull --ff-only
```

---

### Step 2: Safely Inspect System Packages (Dry-Run)
Inspect pending pacman updates to detect matching upstream requirement shifts (e.g. Hyprland 0.56, hypridle Lua dispatchers, Qt 6.11):
```bash
pacman -Qu | grep -E 'hypr|qt6|quickshell|linux|mesa|pipewire' || true
```
> [!NOTE]
> Do NOT blindly install system updates unless the user requests it.

---

### Step 3: Create New Update Bundle
1. Determine bundle name `YYYYMMDD.1` using the date of the last commit.
2. Create directory: `mkdir -p upstream-updates/YYYYMMDD.1`
3. Generate `changes.md`:
   - Include commit range, date range, bulleted summaries, and list of files changed.
4. Generate `apply-changes.sh`:
   - Copy from [.agents/skills/upstream-updater/resources/apply-template.sh](./resources/apply-template.sh).
   - Populate `paths=(...)` with the updated files under `dots/`.
5. Generate `restore-backup.sh`:
   - Copy from [.agents/skills/upstream-updater/resources/restore-template.sh](./resources/restore-template.sh).
6. Set permissions:
   ```bash
   chmod +x upstream-updates/YYYYMMDD.1/apply-changes.sh upstream-updates/YYYYMMDD.1/restore-backup.sh
   ```

---

### Step 4: Synchronize Files into Fork Repository
Copy all approved modified and newly added files from `dots-hyprland` to `end4-dotfiles` (`dots/` and `sdata/`), strictly skipping any excluded components.

#### PKGBUILD Remote Change Caveat (`makepkg` cache cleanup)
If upstream changes a git repository URL in `sdata/dist-arch/<pkg>/PKGBUILD` (e.g. `MicroTeX`), remove old cached clones and build artifacts:
```bash
rm -rf sdata/dist-arch/<pkg>/{<Folder>,src,pkg,*.pkg.tar.zst}
```

---

### Step 5: Quickshell Reload vs. Restart Caveat
> [!IMPORTANT]
> When new QML components/types are added (e.g. `StyledRectangle.qml`, `Box.qml`, `AppIcon.qml`), a **live hot-reload will fail** with `Type is not a type` because Qt QML does not dynamically re-index newly created type files on disk.
>
> **Always do a full daemon restart**:
> ```bash
> pkill -x qs || true
> sleep 1
> qs -c ii -d
> ```

---

### Step 6: Verification & Dry-Run
Run automated validation before concluding:
```bash
# 1. Shell & Lua syntax check
bash -n upstream-updates/YYYYMMDD.1/apply-changes.sh
bash -n upstream-updates/YYYYMMDD.1/restore-backup.sh
luac -p dots/.config/hypr/hyprland.lua dots/.config/hypr/hyprland/*.lua

# 2. Dry-run applicator
bash upstream-updates/YYYYMMDD.1/apply-changes.sh --dry-run

# 3. Check Quickshell status
qs log -c ii | tail -n 25
```
