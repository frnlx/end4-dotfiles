#!/usr/bin/env bash
set -euo pipefail

usage(){
  cat <<EOF
Usage: $0 [timestamp]

Restores backup files created by apply-changes.sh.
If no timestamp is provided, searches for all recent backups.

Examples:
  $0              # List available backups
  $0 1736352000   # Restore specific timestamp
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

TIMESTAMP="${1:-}"

# Base paths where backups might exist
BASE_PATHS=(
  "$HOME/.config/quickshell"
  "$HOME/sdata/subcmd-install"
)

if [[ -z "$TIMESTAMP" ]]; then
  echo "Searching for backup files..."
  found=0
  for base in "${BASE_PATHS[@]}"; do
    if [[ -d "$base" ]]; then
      while IFS= read -r -d '' backup; do
        echo "  $backup"
        found=1
      done < <(find "$base" -name "*.bak.*" -print0 2>/dev/null || true)
    fi
  done
  
  if [[ $found -eq 0 ]]; then
    echo "No backup files found."
    exit 0
  fi
  
  echo ""
  echo "To restore, extract the timestamp from a backup filename (e.g., 1736352000)"
  echo "and run: $0 <timestamp>"
  exit 0
fi

echo "Restoring backups with timestamp: $TIMESTAMP"
restored=0

for base in "${BASE_PATHS[@]}"; do
  if [[ ! -d "$base" ]]; then
    continue
  fi
  
  while IFS= read -r -d '' backup; do
    original="${backup%.bak.$TIMESTAMP}"
    
    if [[ ! -e "$backup" ]]; then
      continue
    fi
    
    echo "Restoring: $original"
    
    # Remove current version if exists
    if [[ -e "$original" || -L "$original" ]]; then
      echo "  removing current: $original"
      rm -rf "$original"
    fi
    
    # Restore backup
    echo "  restoring from: $backup"
    mv "$backup" "$original"
    restored=$((restored + 1))
  done < <(find "$base" -name "*.bak.$TIMESTAMP" -print0 2>/dev/null || true)
done

if [[ $restored -eq 0 ]]; then
  echo "No backups found with timestamp: $TIMESTAMP"
  echo "Run '$0' without arguments to see available backups."
  exit 1
fi

echo ""
echo "Restored $restored file(s). You may want to restart quickshell."
exit 0
