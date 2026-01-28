#!/usr/bin/env bash
set -euo pipefail

# When run from inside upstream-updates/YYYYMMDD.n, repo root is two levels up
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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
# Only dots/ files are included - these will be installed to $HOME
paths=(
  "dots/.config/hypr/hyprland.conf"
  "dots/.config/hypr/hyprland/execs.conf"
  "dots/.config/hypr/hyprland/general.conf"
  "dots/.config/hypr/hyprland/keybinds.conf"
  "dots/.config/hypr/hyprland/rules.conf"
  "dots/.config/quickshell/ii/GlobalStates.qml"
  "dots/.config/quickshell/ii/modules/ii/bar/BarContent.qml"
  "dots/.config/quickshell/ii/modules/ii/dock/DockApps.qml"
  "dots/.config/quickshell/ii/modules/ii/lock/Lock.qml"
  "dots/.config/quickshell/ii/modules/ii/lock/LockSurface.qml"
  "dots/.config/quickshell/ii/modules/ii/lock/PasswordChars.qml"
  "dots/.config/quickshell/ii/modules/ii/regionSelector/CursorGuide.qml"
  "dots/.config/quickshell/ii/modules/ii/regionSelector/RectCornersSelectionDetails.qml"
  "dots/.config/quickshell/ii/modules/ii/regionSelector/RegionSelection.qml"
  "dots/.config/quickshell/ii/modules/ii/sidebarRight/BottomWidgetGroup.qml"
  "dots/.config/quickshell/ii/modules/ii/sidebarRight/bluetoothDevices/BluetoothDeviceItem.qml"
  "dots/.config/quickshell/ii/modules/ii/sidebarRight/wifiNetworks/WifiNetworkItem.qml"
  "dots/.config/quickshell/ii/modules/waffle/actionCenter/bluetooth/BluetoothDeviceItem.qml"
  "dots/.config/quickshell/ii/modules/waffle/actionCenter/wifi/WWifiNetworkItem.qml"
  "dots/.config/quickshell/ii/services/Brightness.qml"
  "dots/.config/quickshell/ii/shell.qml"
  "dots/.config/quickshell/ii/translations/de_DE.json"
  "dots/.config/quickshell/ii/translations/id_ID.json"
  "dots/.config/quickshell/ii/translations/pt_BR.json"
)

# Files that should be removed (deleted in upstream)
removed_paths=(
  "dots/.config/quickshell/ii/modules/ii/regionSelector/OptionsToolbar.qml"
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

# Handle removed files
for p in "${removed_paths[@]}"; do
  rel="${p#dots/}"
  dest="$HOME/$rel"
  if [[ -e "$dest" || -L "$dest" ]]; then
    echo "Processing removal: $dest"
    if [[ $DRY_RUN -eq 1 ]]; then
      echo "  (dry-run) would backup and remove: $dest"
      continue
    fi
    bak="$dest.bak.$BACKUP_TS"
    echo "  backing up before removal: $dest -> $bak"
    mv -T "$dest" "$bak"
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
