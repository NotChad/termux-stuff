#!/bin/sh
set -e -u

VERSION="1.1.19"

CUR_SCRIPT_DIR=$(dirname "$(realpath "${0}")")
SCRIPTS_DIR="${CUR_SCRIPT_DIR}/../scripts"
. "${SCRIPTS_DIR}/envsetup.sh"

do_cleanup() {
    rm -rf "${TERMUX_BUILD_DIR}/musl-${VERSION}"
    rm -rf "${TERMUX_BUILD_DIR}/musl-${VERSION}-install"
}

if [ ! -e "${TERMUX_SOURCE_CACHE_DIR}/musl-${VERSION}.tar.gz" ]; then
    curl \
        -o "${TERMUX_SOURCE_CACHE_DIR}/musl-${VERSION}.tar.gz" \
        "http://www.musl-libc.org/releases/musl-${VERSION}.tar.gz"
fi

do_cleanup

cd "${TERMUX_BUILD_DIR}" && {
    tar xf "${TERMUX_SOURCE_CACHE_DIR}/musl-${VERSION}.tar.gz"
}

cd "${TERMUX_BUILD_DIR}/musl-${VERSION}" && {
    for p in ${CUR_SCRIPT_DIR}/patches/musl/*.patch; do
        patch -p1 -i $p
    done
    unset p

    LDFLAGS="-Wl,-soname,libc.musl-${TERMUX_ARCH}.so.1" \
    ./configure \
        --build="${TERMUX_CHOST}" \
        --host="${TERMUX_CTARGET}" \
        --prefix="${TERMUX_PREFIX}" \
        --sysconfdir="${TERMUX_PREFIX}/etc" \
        --syslibdir="${TERMUX_PREFIX}/lib" \
        --mandir="${TERMUX_PREFIX}/share/man" \
        --infodir="${TERMUX_PREFIX}/share/info" \
        --localstatedir="${TERMUX_PREFIX}/share/var"

    make
    make install DESTDIR="${TERMUX_BUILD_DIR}/musl-${VERSION}-install"
}

cd "${TERMUX_BUILD_DIR}/musl-${VERSION}-install/${TERMUX_PREFIX}" && {
    rm -f "${TERMUX_OUTPUT_DIR}/musl-libc.tar.gz"
    tar zcf "${TERMUX_OUTPUT_DIR}/musl-libc.tar.gz" include lib
}

do_cleanup
