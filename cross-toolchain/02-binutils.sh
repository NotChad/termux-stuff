#!/bin/sh
set -e -u

VERSION="2.30"

CUR_SCRIPT_DIR=$(dirname "$(realpath "${0}")")
SCRIPTS_DIR="${CUR_SCRIPT_DIR}/../scripts"
. "${SCRIPTS_DIR}/envsetup.sh"

do_cleanup() {
    rm -rf "${TERMUX_BUILD_DIR}/binutils-${VERSION}"
    rm -rf "${TERMUX_BUILD_DIR}/binutils-${VERSION}-install"
}

if [ ! -e "${TERMUX_SOURCE_CACHE_DIR}/binutils-${VERSION}.tar.bz2" ]; then
    curl \
        -o "${TERMUX_SOURCE_CACHE_DIR}/binutils-${VERSION}.tar.bz2" \
        "http://ftp.gnu.org/gnu/binutils/binutils-${VERSION}.tar.bz2"
fi

do_cleanup

cd "${TERMUX_BUILD_DIR}" && {
    tar xf "${TERMUX_SOURCE_CACHE_DIR}/binutils-${VERSION}.tar.bz2"
}

cd "${TERMUX_BUILD_DIR}/binutils-${VERSION}" && {
    for p in ${CUR_SCRIPT_DIR}/patches/binutils/*.patch; do
        patch -p1 -i $p
    done
    unset p

    ./configure \
        --build="${TERMUX_CHOST}" \
        --host="${TERMUX_CHOST}" \
        --target="${TERMUX_CTARGET}" \
        --with-sysroot="${CROSS_TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}" \
        --prefix="${CROSS_TOOLCHAIN_PREFIX}" \
        --mandir="${CROSS_TOOLCHAIN_PREFIX}/share/man" \
        --infodir="${CROSS_TOOLCHAIN_PREFIX}/share/info" \
        --enable-ld=default \
        --enable-gold=yes \
        --enable-64-bit-bfd \
        --enable-plugins \
        --enable-relro \
        --enable-deterministic-archives \
        --disable-install-libiberty \
        --enable-default-hash-style=gnu \
        --with-pic \
        --disable-werror \
        --disable-nls \
        --with-system-zlib

    make -j4
    make install DESTDIR="${TERMUX_BUILD_DIR}/binutils-${VERSION}-install"
}

cd "${TERMUX_BUILD_DIR}/binutils-${VERSION}-install/${CROSS_TOOLCHAIN_PREFIX}" && {
    rm -f "${TERMUX_OUTPUT_DIR}/binutils-cross.tar.gz"
    tar zcf "${TERMUX_OUTPUT_DIR}/binutils-cross.tar.gz" aarch64-unknown-linux-musl bin share
}

do_cleanup
