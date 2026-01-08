#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DRY_RUN=0
RESTART=0
BACKUP_TS="$(date +%s)"

usage(){
  cat <<EOF
Usage: $0 [--dry-run|-n] [--restart|-r]

Options:
  -n, --dry-run   Show what will be done without making changes
  -r, --restart   Attempt to restart quickshell (or pkill it)
  -h, --help      Show this help
EOF
}

while [[ ${#} -gt 0 ]]; do
  case "$1" in
    -n|--dry-run) DRY_RUN=1; shift ;;
    -r|--restart) RESTART=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 2 ;;
  esac
done

# Files and directories updated in the upstream merge (relative to repo root)
paths=(
  "dots/.config/quickshell/ii/modules/ii/lock/Lock.qml"
  "dots/.config/quickshell/ii/modules/ii/background/widgets/clock/ClockWidget.qml"
  "dots/.config/quickshell/ii/modules/ii/background/widgets/clock/DigitalClock.qml"
  "dots/.config/quickshell/ii/modules/ii/overview/Overview.qml"
  "dots/.config/quickshell/ii/modules/ii/overview/OverviewWidget.qml"
  "dots/.config/quickshell/ii/modules/common/widgets/shapes"
  "dots/.config/quickshell/ii/modules/settings/QuickConfig.qml"
  "dots/.config/quickshell/ii/modules/ii/bar/Bar.qml"
  "dots/.config/quickshell/ii/modules/ii/cheatsheet/Cheatsheet.qml"
  "dots/.config/quickshell/ii/modules/ii/mediaControls/MediaControls.qml"
  "dots/.config/quickshell/ii/modules/ii/onScreenKeyboard/OnScreenKeyboard.qml"
  "dots/.config/quickshell/ii/modules/ii/sidebarLeft/SidebarLeft.qml"
  "dots/.config/quickshell/ii/modules/ii/sidebarRight/SidebarRight.qml"
  "dots/.config/quickshell/ii/modules/ii/verticalBar/VerticalBar.qml"
  "dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperSelector.qml"
  "dots/.config/quickshell/ii/services/GlobalFocusGrab.qml"
  "dots/.config/quickshell/ii/modules/ii/overview/SearchWidget.qml"
  "dots/.config/quickshell/ii/services/Network.qml"
  "dots/.config/quickshell/ii/modules/ii/overview/SearchBar.qml"
  "dots/.config/quickshell/ii/modules/ii/wallpaperSelector/WallpaperDirectoryItem.qml"
  "dots/.config/quickshell/ii/scripts/thumbnails/thumbgen-venv.sh"
  "dots/.config/quickshell/ii/modules/ii/bar/weather/WeatherPopup.qml"
  "dots/.config/quickshell/ii/services/Weather.qml"
)

echo "Repo root: $REPO_ROOT"
echo "Dry run: $DRY_RUN"

for p in "${paths[@]}"; do
  src="$REPO_ROOT/$p"
  if [[ ! -e "$src" ]]; then
    echo "[SKIP] source not found: $src"
    continue
  fi
  # destination path: strip leading "dots/" so that "dots/.config/..." -> "$HOME/.config/..."
  rel="${p#dots/}"
  dest="$HOME/$rel"
  destdir="$(dirname "$dest")"
  echo "Processing: $src -> $dest"
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "  (dry-run) ensure dir: $destdir"
    if [[ -d "$src" ]]; then
      echo "  (dry-run) rsync -a --delete $src/ $dest/"
    else
      echo "  (dry-run) copy file $src -> $dest"
    fi
    continue
  fi

  mkdir -p "$destdir"
  if [[ -e "$dest" || -L "$dest" ]]; then
    bak="$dest.bak.$BACKUP_TS"
    echo "  backing up existing $dest -> $bak"
    mv -T "$dest" "$bak"
  fi

  if [[ -d "$src" ]]; then
    echo "  rsyncing directory"
    rsync -a --delete "$src/" "$dest/"
  else
    echo "  copying file"
    cp -a "$src" "$dest"
  fi
done

if [[ $RESTART -eq 1 ]]; then
  echo "Attempting to restart quickshell (if running)..."
  if systemctl --user --quiet status quickshell.service 2>/dev/null; then
    echo "  restarting systemd --user unit quickshell.service"
    systemctl --user restart quickshell.service || echo "  systemctl restart failed"
  else
    if pgrep -f quickshell >/dev/null 2>&1; then
      echo "  pkill -f quickshell (will exit processes and let any autostart handle restart)"
      pkill -f quickshell || true
    else
      echo "  quickshell not running"
    fi
  fi
fi

echo "Done. Backups kept as *.bak.$BACKUP_TS where applicable."

exit 0
