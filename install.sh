#!/usr/bin/env bash
# Build a watch face module and install it on the watch over adb (macOS/Linux).
#
#   ./install.sh                                   # builds :terminal-themes (debug)
#   ./install.sh terminal-themes 192.168.1.50:41234   # module + ip:port from Wireless debugging
set -euo pipefail
cd "$(dirname "$0")"

MODULE="${1:-terminal-themes}"
CONNECT="${2:-}"

if [[ -x ./gradlew ]]; then GRADLE=./gradlew; else GRADLE=gradle; fi
"$GRADLE" ":${MODULE}:assembleDebug"

if [[ -n "$CONNECT" ]]; then
  adb connect "$CONNECT"
fi

APK=$(ls "${MODULE}"/build/outputs/apk/debug/*.apk | head -n 1)
[[ -f "$APK" ]] || { echo "No APK found for ${MODULE}" >&2; exit 1; }

adb install -r "$APK"
echo "Installed $(basename "$APK"). On the watch: long-press the face -> + -> pick it."
