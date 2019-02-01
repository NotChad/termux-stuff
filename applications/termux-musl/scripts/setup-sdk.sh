#!/bin/sh
set -e

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")

if [ ! -f "$SCRIPT_DIR/termux-config.sh" ]; then
    echo "[!] termux-config.sh missing."
    exit 1
fi

. "$SCRIPT_DIR/termux-config.sh"

yes | "$ANDROID_HOME/tools/bin/sdkmanager" --licenses
"$ANDROID_HOME/tools/bin/sdkmanager" "build-tools;${TERMUX_ANDROID_BUILD_TOOLS_VERSION}" "platforms;android-27" "platforms;android-21"
