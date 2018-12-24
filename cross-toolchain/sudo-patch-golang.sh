#!/bin/bash
##
##  Requires root privileges !.
##

if [ "$(id -u)" != "0" ]; then
    echo "This script requires root privileges!"
    exit 1
fi

SCRIPT_PATH=$(realpath "${0}")
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
TERMUX_CONFIG=$(realpath "${SCRIPT_DIR}/../scripts/termux-config.sh")

if [ -f "${TERMUX_CONFIG}" ]; then
    . "${TERMUX_CONFIG}"
fi

: "${TERMUX_ARCH:="aarch64"}"
: "${TERMUX_PREFIX:="/data/data/com.termux/files/usr"}"
: "${TERMUX_HOME:="/data/data/com.termux/files/home"}"

cd /usr/lib/go/src && {
    echo "[*] Patching Go runtime sources..."
    cat "${SCRIPT_DIR}/go/go-runtime-termux-compat.patch" | \
        sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" | \
            sed "s%\@TERMUX_HOME\@%${TERMUX_HOME}%g" | \
                patch -p1
}
