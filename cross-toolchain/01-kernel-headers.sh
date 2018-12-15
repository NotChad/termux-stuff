#!/bin/sh
set -e -u

VERSION="3.16.61"

SCRIPTS_DIR=$(dirname "$(realpath "${0}")")/../scripts
. "${SCRIPTS_DIR}/envsetup.sh"

do_cleanup() {
    rm -rf "${TERMUX_BUILD_DIR}/linux-${VERSION}"
    rm -rf "${TERMUX_BUILD_DIR}/linux-${VERSION}-install"
}

if [ ! -e "${TERMUX_SOURCE_CACHE_DIR}/linux-${VERSION}.tar.xz" ]; then
    curl \
        -o "${TERMUX_SOURCE_CACHE_DIR}/linux-${VERSION}.tar.xz" \
        "https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-${VERSION}.tar.xz"
fi

do_cleanup

cd "${TERMUX_BUILD_DIR}" && {
    tar xf "${TERMUX_SOURCE_CACHE_DIR}/linux-${VERSION}.tar.xz"
}

cd "${TERMUX_BUILD_DIR}/linux-${VERSION}" && {
    if [ "${TERMUX_ARCH}" = "aarch64" ]; then
        TERMUX_ARCH="arm64"
    fi

    make mrproper
    make ARCH="${TERMUX_ARCH}" headers_check
    make ARCH="${TERMUX_ARCH}" INSTALL_HDR_PATH="${TERMUX_BUILD_DIR}/linux-${VERSION}-install" headers_install
}

cd "${TERMUX_BUILD_DIR}/linux-${VERSION}-install" && {
    find include -type f -iname .install -delete
    find include -type f -iname ..install.cmd -delete
    rm -f "${TERMUX_OUTPUT_DIR}/linux-headers.tar.gz"
    tar zcf "${TERMUX_OUTPUT_DIR}/linux-headers.tar.gz" include
}

do_cleanup
