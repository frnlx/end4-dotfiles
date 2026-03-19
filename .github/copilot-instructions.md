# Copilot Instructions for end_4's Hyprland Dotfiles

This is a **lightweight fork** of [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland) (also known as **illogical-impulse**) with the following components removed:

- ❌ **AI Chat** - Sidebar AI assistant (Gemini, OpenAI, Ollama integrations)
- ❌ **Anime/Booru** - Anime wallpaper browser and downloader
- ❌ **Translator** - translate-shell integration

Everything else from the original dotfiles remains intact. This fork maintains compatibility with upstream and aims for reduced complexity, privacy, and a smaller footprint.

## Project Structure

- **`dots/`** - User configuration files (installed to `$HOME/`)
  - `.config/quickshell/ii/` - Quickshell (Qt/QML) configuration for the desktop shell
  - `.config/hypr/` - Hyprland compositor configuration
  - `.config/fish/`, `.config/kitty/`, `.config/fuzzel/` etc. - Other app configs
- **`sdata/`** - Setup scripts and installation data
  - `lib/` - Shared bash functions and environment variables
  - `dist-{arch,fedora,gentoo,nix}/` - Distribution-specific dependency installers
  - `subcmd-*/` - Subcommands for `./setup` script
  - `uv/` - Python virtual environment requirements
- **`upstream-updates/`** - Individual merge bundles from upstream for manual application
- **`setup`** - Main installation/management script (replaces old `install.sh`, `update.sh`, `uninstall.sh`)
- **`diagnose`** - Diagnostic script to generate system info for debugging

## Installation

**Quick install** (using upstream installer):
```bash
bash <(curl -s https://ii.clsty.link/get)
```

**Manual install** (clone this repo):
```bash
git clone <this-repo-url>
cd end4-dotfiles
./setup install
```

**Remove AI/Anime/Translator from existing upstream installation**:
```bash
./remove-ai-anime-translator.sh
```

## Setup & Management Commands

```bash
# Install/reinstall illogical-impulse (run from repo root)
./setup install

# Partial installation steps
./setup install-deps     # Install dependencies only
./setup install-setups   # Run permission/service setup only
./setup install-files    # Copy config files only

# Update (experimental - updates without full reinstall)
./setup exp-update

# Merge upstream changes with local configs (experimental)
./setup exp-merge

# Uninstall
./setup uninstall

# Generate diagnostic info (creates diagnose.result file)
./diagnose
```

**For subcommand help**: `./setup <subcommand> -h`

## Development Workflow

### Working with Quickshell (QML)

Quickshell is the desktop shell built with Qt/QML. Config located at `dots/.config/quickshell/ii/`.

**Setup for development**:
```bash
# Install minimal requirements (Arch)
yay -S hyprland quickshell-git

# Copy quickshell config
cp -r dots/.config/quickshell ~/.config/

# Setup LSP support
touch ~/.config/quickshell/ii/.qmlls.ini
```

**VSCode setup**: Install "Qt Qml" extension, set custom exe path to `/usr/bin/qmlls6`

**Running & testing**:
```bash
# Launch Hyprland (not "uwsm-managed" session)
# Kill and restart Quickshell with logs
pkill qs; qs -c ii

# Changes reload live - just edit and save
```

### Quickshell Code Conventions

From `CONTRIBUTING.md`:

1. **Dynamic loading** - Use `Loader` for optional/configurable features
   - Declare positioning properties (`anchors`) in `Loader`, not `sourceComponent`
   - Use `FadeLoader` for non-layout-affecting elements (set `shown` instead of `active`/`visible`)

2. **Resource efficiency** - Don't add heavy features for minor purposes
   - Fancy/impractical features must have config option and default to disabled
   - Example: constantly rotating background clock

3. **Code style**:
   - Use spaces, not tabs
   - Group properties and children into meaningful sections (avoid 2+ consecutive blank lines)
   - Space around operators: `if (condition) { ... } else { ... }`
   - Prefer early return to reduce nesting
   - Use `component` for reusable components within same file

## Python Virtual Environment

Python packages are installed in virtual environment (not system-wide) to avoid package conflicts.

**Location**: `$ILLOGICAL_IMPULSE_VIRTUAL_ENV` (defaults to `~/.local/state/quickshell/.venv`)

**Managing dependencies**:
1. Edit `sdata/uv/requirements.in` (see [PyPI](https://pypi.org/) for packages)
2. Compile: `uv pip compile requirements.in -o requirements.txt` (from `sdata/uv/`)

**Using venv in scripts**:

Option A - Shebang for simple python scripts:
```python
#!/usr/bin/env -S /bin/sh -c "source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate&&exec python -E "$0" "$@""
```
**Limitation**: Can't handle complex arguments with spaces

Option B - Bash wrapper (recommended):
```bash
#!/usr/bin/env bash
PY_SCRIPT="$(cd $(dirname "${BASH_SOURCE[0]}") && pwd)/script.py"
source $(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate
"$PY_SCRIPT" "$@"
deactivate
```

Option C - Inside bash scripts:
```bash
source "$(eval echo $ILLOGICAL_IMPULSE_VIRTUAL_ENV)/bin/activate"
python3 my_script.py
deactivate
```

## Key Architecture Components

### Quickshell Structure

- **`shell.qml`** - Root shell file, loads panel families (ii, waffle)
- **`modules/`** - Reusable QML components organized by function
  - `common/` - Shared utilities (Appearance, Directories)
  - `ii/` - illogical-impulse specific modules
  - `settings/` - Configuration modules
  - `waffle/` - Alternative panel family
- **`services/`** - Backend services (Audio, Battery, Network, Notifications, etc.)
- **`panelFamilies/`** - Different UI layouts (ii, waffle)
- **`scripts/`** - Helper bash/python scripts
- **`translations/`** - i18n support

### Hyprland Configuration

Location: `dots/.config/hypr/`

- **`hyprland.conf`** - Main config file
- **`hyprland/`** subdirectory contains:
  - `keybinds.conf` - Keyboard shortcuts (uses `quickshell:` IPC calls)
  - `env.conf` - Environment variables
  - Other split config files
- **`monitors.conf`**, **`workspaces.conf`** - Display setup
- **`hypridle.conf`**, **`hyprlock.conf`** - Idle/lock screen

### Setup Script Architecture

The `./setup` script uses a modular design:

1. Sources from `sdata/lib/`:
   - `environment-variables.sh` - XDG paths, style variables, backup dirs
   - `functions.sh` - Helper functions
   - `package-installers.sh` - Package installation logic
   - `dist-determine.sh` - Detect OS distribution

2. Routes to `sdata/subcmd-*/` based on subcommand

3. For `install`, runs sequentially:
   - `0.greeting.sh` - Welcome message
   - `1.deps-router.sh` - Install dependencies (routes to dist-specific scripts)
   - `2.setups.sh` - Configure permissions/services
   - `3.files.sh` - Copy config files

4. Uses sudo keepalive mechanism during install (auto-refreshes sudo timeout)

## Distribution Support

Primary: **Arch Linux** (`sdata/dist-arch/`) - actively maintained

Secondary: Fedora, Gentoo, NixOS (may be less up-to-date)

### Dependency System

Packages prefixed with `illogical-impulse-*` are defined in local `PKGBUILD` files:

- **Meta packages** - Bundle dependencies (e.g., `illogical-impulse-audio`)
- **Actual packages** - Build and install content (e.g., `illogical-impulse-quickshell-git`)

See `sdata/deps-info.md` for complete dependency documentation.

Key dependencies:
- `quickshell-git` (pinned commit) - Desktop shell
- `hyprland` - Wayland compositor
- `matugen-bin` - Material You color theming
- `uv` - Python virtual environment manager

## Upstream Sync

This fork maintains compatibility with upstream. See `upstream-updates/README.md` for merge bundle structure.

Each `upstream-updates/YYYYMMDD.n/` contains:
- `changes.md` - Changelog with commit range and file changes
- `apply-changes.sh` - Apply updates (supports `--dry-run`, `--restart`)
- `restore-backup.sh` - Rollback mechanism

**To apply upstream updates**:
```bash
cd upstream-updates/20260104.1/
./apply-changes.sh --dry-run  # Preview changes
./apply-changes.sh            # Apply
./apply-changes.sh --restart  # Apply and restart Quickshell
```

## Environment Variables

Defined in `sdata/lib/environment-variables.sh`:

```bash
XDG_CONFIG_HOME=${XDG_CONFIG_HOME:-$HOME/.config}
XDG_STATE_HOME=${XDG_STATE_HOME:-$HOME/.local/state}
ILLOGICAL_IMPULSE_VIRTUAL_ENV=${XDG_STATE_HOME}/quickshell/.venv
BACKUP_DIR=${BACKUP_DIR:-$HOME/ii-original-dots-backup}
DOTS_CORE_CONFDIR=${XDG_CONFIG_HOME}/illogical-impulse
```

## Common Hyprland IPC Calls

The config uses many `global, quickshell:*` IPC calls to communicate between Hyprland and Quickshell:

- `quickshell:searchToggleRelease` - Toggle launcher
- `quickshell:overviewWorkspacesToggle` - Toggle workspace overview
- `quickshell:overviewClipboardToggle` - Clipboard history
- `quickshell:overviewEmojiToggle` - Emoji picker
- `quickshell:sidebarLeftToggle` / `quickshell:sidebarRightToggle` - Sidebars
- `quickshell:cheatsheetToggle` - Show keybindings
- `quickshell:barToggle` - Toggle status bar

## Testing & Validation

No formal test suite. Manual testing workflow:

1. Test on clean Arch install or new user profile
2. Run `./setup install`
3. Launch Hyprland
4. Verify Quickshell loads: `pkill qs; qs -c ii`
5. Check for errors in terminal output
6. Test key features (launcher, sidebars, screenshot, etc.)

For bug reports, run `./diagnose` and include the `diagnose.result` file.

## Contributing Guidelines

From `CONTRIBUTING.md`:

- **Multiple PRs** - Don't bundle unrelated features/fixes
- **No personal defaults** - Keep PRs focused on the feature, not your config tweaks
- **Configurable features** - Features we don't personally use should be optional
- **Ask before big work** - Check if maintainers want the feature before investing time

## Resources & Credits

- **Upstream repository**: [end-4/dots-hyprland](https://github.com/end-4/dots-hyprland)
- **Documentation**: [ii.clsty.link](https://ii.clsty.link/en/ii-qs/01setup/)
- **Discord**: [Join](https://discord.gg/GtdRBXgMwq)
- **Credits**: All credit goes to [@end-4](https://github.com/end-4) and contributors of the original dotfiles

**Note**: Most changes in this fork were made with the help of AI tools.
