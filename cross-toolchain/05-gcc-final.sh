#!/bin/sh
set -e -u

VERSION="6.4.0"

CUR_SCRIPT_DIR=$(dirname "$(realpath "${0}")")
SCRIPTS_DIR="${CUR_SCRIPT_DIR}/../scripts"
. "${SCRIPTS_DIR}/envsetup.sh"

do_cleanup() {
    rm -rf "${TERMUX_BUILD_DIR}/gcc-${VERSION}"
    rm -rf "${TERMUX_BUILD_DIR}/gcc-${VERSION}-install"
}

if [ ! -e "${TERMUX_SOURCE_CACHE_DIR}/gcc-${VERSION}.tar.bz2" ]; then
    curl \
        -o "${TERMUX_SOURCE_CACHE_DIR}/gcc-${VERSION}.tar.bz2" \
        "http://gcc.gnu.org/pub/gcc/releases/gcc-6.4.0/gcc-${VERSION}.tar.xz"
fi

do_cleanup

cd "${TERMUX_BUILD_DIR}" && {
    tar xf "${TERMUX_SOURCE_CACHE_DIR}/gcc-${VERSION}.tar.bz2"
}

cd "${TERMUX_BUILD_DIR}/gcc-${VERSION}" && {
    for p in ${CUR_SCRIPT_DIR}/patches/gcc/*.patch; do
        patch -p1 -F3 -i $p
    done
    unset p

    cd "${CROSS_TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}" && {
        rm -f usr && ln -s .. usr
        cd -
    }

    mkdir build && cd build

    ../configure \
        --prefix="${CROSS_TOOLCHAIN_PREFIX}" \
        --build="${TERMUX_CHOST}" \
        --host="${TERMUX_CHOST}" \
        --target="${TERMUX_CTARGET}" \
        --with-pkgversion="Termux ${VERSION}" \
        --enable-checking=release \
        --disable-fixed-point \
        --disable-libstdcxx-pch \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --disable-symvers \
        --enable-__cxa_atexit \
        --enable-default-pie \
        --enable-cloog-backend \
        --enable-languages=c,c++ \
        --with-arch=armv8-a \
        --with-abi=lp64 \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libmpx \
        --disable-libmudflap \
        --disable-libsanitizer \
        --disable-bootstrap \
        --with-sysroot="${CROSS_TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}" \
        --disable-libgomp \
        --disable-libatomic \
        --disable-libitm \
        --enable-threads \
        --enable-shared \
        --enable-tls \
        --with-system-zlib \
        --with-linker-hash-style=gnu

    export libat_cv_have_ifunc=no

    make -j4
    make -j1 install DESTDIR="${TERMUX_BUILD_DIR}/gcc-${VERSION}-install"
}

cd "${TERMUX_BUILD_DIR}/gcc-${VERSION}-install/${CROSS_TOOLCHAIN_PREFIX}" && {
    scanelf -R . | grep -P 'ET_(EXEC|DYN)' | awk '{ print $2 }' | xargs -r file | grep x86-64 | cut -d: -f1 | xargs -r strip --strip-unneeded
    rm -f "${TERMUX_OUTPUT_DIR}/gcc-final-cross.tar.gz"
    tar zcf "${TERMUX_OUTPUT_DIR}/gcc-final-cross.tar.gz" aarch64-unknown-linux-musl bin include lib libexec share
}

do_cleanup
