#!/bin/bash

# logging
log() {
  local type="$1"; shift
  local color
  case "$type" in
    INFO)  color='\033[0;35m' ;;  # Cyan
    WARN)  color='\033[0;33m' ;;
    ERROR) color='\033[0;31m' ;;
    DONE)  color='\033[0;37m' ;;
    *)     color='\033[0m'   ;;
  esac
  echo -e "${color}[${type}]${NC} $*"
}

if [ -z "$1" ]; then
  echo "Usage: $0 <soundcloud_playlist_url> [--debug]"
  exit 1
fi

URL="$1"
DEBUG=0
[[ "$2" == "--debug" ]] && DEBUG=1
NC='\033[0m'

RAWNAME=$(basename "$URL")
NAME=$(echo "$RAWNAME" | tr -d '\r' | tr ' ' '_' | sed 's/[^a-zA-Z0-9_-]/_/g')

if [ -z "$NAME" ]; then
  NAME="playlist_$(date +%s)"
  log WARN "ERR Acquing PlayList name, using fallback: $NAME"
fi

DEST="$HOME/Music/SoundCloud/$NAME"
mkdir -p "$DEST"

log INFO "Downloading: $URL"
log INFO "Target folder: $DEST"

CMD=(
  scdl -l "$URL"
  --path "$DEST"
  --addtofile
  --onlymp3
  --original-art
  --force-metadata
  --name-format "{playlist_index} - {title}"
  --download-archive "$HOME/.scdl_album_archive.txt"
)

[ $DEBUG -eq 1 ] && CMD+=(--debug)

log INFO "Your download is starting."

#exec
"${CMD[@]}" 2>&1 | while IFS= read -r line; do
  if [[ "$line" =~ Downloading ]]; then
    log INFO "$line"
  elif [[ "$line" =~ ERROR ]]; then
    log ERROR "$line"
  elif [[ "$line" =~ WARNING ]]; then
    log WARN "$line"
  else
    echo "$line"
  fi
done

log DONE "Downloaded: $NAME"
