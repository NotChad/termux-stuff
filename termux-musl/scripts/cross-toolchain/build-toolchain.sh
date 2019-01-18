#!/bin/bash
##
##  Script for building a cross-compiler.
##  Use it only with supplied docker image.
##
##  Building toolchain for default architecture:
##
##    ./build-toolchain.sh
##
##  Building for specified architecture. Example for 'arm':
##
##    TERMUX_ARCH=arm ./build-toolchain.sh
##

set -e -u

## Don't modify these variables without good reason.
KERNEL_VERSION="3.16.61"
KERNEL_SHA256="42d5f6c46d9e4b1dbff04344fef441b219067753dc519c689106fab7e4444d4c"

BINUTILS_VERSION="2.31.1"
BINUTILS_SHA256="e88f8d36bd0a75d3765a4ad088d819e35f8d7ac6288049780e2fefcad18dde88"

GCC_VERSION="8.2.0"
GCC_SHA256="196c3c04ba2613f893283977e6011b2345d1cd1af9abeac58e916b1aab3e0080"

MUSL_LIBC_VERSION="1.1.20"
MUSL_LIBC_SHA256="44be8771d0e6c6b5f82dd15662eb2957c9a3173a19a8b49966ac0542bbd40d61"

################################################################################

KERNEL_URL="https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-${KERNEL_VERSION}.tar.xz"
BINUTILS_URL="https://mirrors.kernel.org/gnu/binutils/binutils-${BINUTILS_VERSION}.tar.gz"
GCC_URL="http://mirrors.kernel.org/gnu/gcc/gcc-${GCC_VERSION:0:3}.0/gcc-${GCC_VERSION}.tar.xz"
MUSL_LIBC_URL="http://www.musl-libc.org/releases/musl-${MUSL_LIBC_VERSION}.tar.gz"

SCRIPT_PATH=$(realpath "${0}")
SCRIPT_DIR=$(dirname "${SCRIPT_PATH}")
TERMUX_CONFIG=$(realpath "${SCRIPT_DIR}/../termux-config.sh")

if [ -f "${TERMUX_CONFIG}" ]; then
    . "${TERMUX_CONFIG}"
fi

: "${TERMUX_ARCH:="aarch64"}"
: "${TERMUX_PREFIX:="/data/data/com.termux.musl/files/usr"}"
: "${TERMUX_HOME:="/data/data/com.termux.musl/files/home"}"
: "${TOOLCHAIN_BASE_DIR:="/opt/termux"}"
: "${TOOLCHAIN_BUILD_MAKE_JOBS:="$(nproc)"}"

TERMUX_CHOST="x86_64-cross-linux-gnu"
if [ "${TERMUX_ARCH}" = "aarch64" ]; then
    TERMUX_CTARGET="aarch64-termux-linux-musl"
elif [ "${TERMUX_ARCH}" = "arm" ]; then
    TERMUX_CTARGET="armv7-termux-linux-musleabihf"
elif [ "${TERMUX_ARCH}" = "i686" ]; then
    TERMUX_CTARGET="i686-termux-linux-musl"
elif [ "${TERMUX_ARCH}" = "x86_64" ]; then
    TERMUX_CTARGET="x86_64-termux-linux-musl"
else
    echo "[!] Allowed TERMUX_ARCH values are: aarch64, arm, i686, x86_64"
    exit 1
fi

## CPP fix: some configure scripts search for 'cpp' in /lib but
## Alpine Linux doesn't provide /lib/cpp. Only /usr/bin/cpp.
export CPP="/usr/bin/cpp"

TOOLCHAIN_BUILD_DIR="${HOME}/.toolchain_build"
TOOLCHAIN_OUTPUT_DIR_NAME="toolchain-${TERMUX_ARCH}"
TOOLCHAIN_OUTPUT_DIR="${TOOLCHAIN_BUILD_DIR}/${TOOLCHAIN_OUTPUT_DIR_NAME}"
TOOLCHAIN_PREFIX="${TOOLCHAIN_BASE_DIR}/${TOOLCHAIN_OUTPUT_DIR_NAME}"

mkdir -p "${TOOLCHAIN_BUILD_DIR}"
mkdir -p "${TOOLCHAIN_OUTPUT_DIR}"
mkdir -p "${TOOLCHAIN_PREFIX}"

## Add our cross-compiler to the PATH.
export PATH="${PATH}:${TOOLCHAIN_PREFIX}/bin"

download_file() {
    local dest="${1}"
    local url="${2}"
    local sha256="${3}"
    local actual_sha256

    if [ -e "${dest}" ]; then
        actual_sha256=$(sha256sum "${dest}" | awk '{ print $1}')
        if [ "${sha256}" != "${actual_sha256}" ]; then
            rm -f "${dest}"
            curl -o "${dest}" "${url}"
        fi
    else
        curl -o "${dest}" "${url}"

        actual_sha256=$(sha256sum "${dest}" | awk '{ print $1}')
        if [ "${sha256}" != "${actual_sha256}" ]; then
            echo "[!] Bad checksum for '${url}'."
            echo "    Actual SHA256: ${actual_sha256}"
            echo "    Expected:      ${sha256}"
            exit 1
        fi
    fi
}

store_built_files() {
    local name="${1}"
    local from="${2}"

    cd "${from}"
    rm -f "${TOOLCHAIN_BUILD_DIR}/${name}"
    tar zcf "${TOOLCHAIN_BUILD_DIR}/${name}" "${TOOLCHAIN_OUTPUT_DIR_NAME}"
    rm -rf "${TOOLCHAIN_OUTPUT_DIR}"
}

echo "[!] Removing previous toolchain..."
rm -rf "${TOOLCHAIN_PREFIX}"

## You may comment out some commands if you need to rebuild only specific parts.
rm -rf "${TOOLCHAIN_BUILD_DIR}/linux-headers-pkg.tar.gz"
rm -rf "${TOOLCHAIN_BUILD_DIR}/binutils-pkg.tar.gz"
rm -rf "${TOOLCHAIN_BUILD_DIR}/gcc-bootstrap-pkg.tar.gz"
rm -rf "${TOOLCHAIN_BUILD_DIR}/musl-pkg.tar.gz"
rm -rf "${TOOLCHAIN_BUILD_DIR}/gcc-final-pkg.tar.gz"

################################################################################
##
##  Building kernel headers.
##

if [ ! -e "${TOOLCHAIN_BUILD_DIR}/linux-headers-pkg.tar.gz" ]; then
    echo "[*] Building Linux API headers..."
    mkdir -p "${TOOLCHAIN_BUILD_DIR}/kernel-headers"
    cd "${TOOLCHAIN_BUILD_DIR}/kernel-headers"

    download_file kernel-src.tar.xz "${KERNEL_URL}" "${KERNEL_SHA256}"
    rm -rf "linux-${KERNEL_VERSION}"
    tar xf kernel-src.tar.xz
    cd "linux-${KERNEL_VERSION}"

    _ARCH=""
    if [ "${TERMUX_ARCH}" = "aarch64" ]; then
        _ARCH="arm64"
    elif [ "${TERMUX_ARCH}" = "i686" ]; then
        _ARCH="x86"
    else
        _ARCH="${TERMUX_ARCH}"
    fi

    make mrproper
    make ARCH="${_ARCH}" headers_check
    make \
        ARCH="${_ARCH}" \
        INSTALL_HDR_PATH="${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}" headers_install

    find "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/include" -type f -iname .install -delete
    find "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/include" -type f -iname ..install.cmd -delete

    store_built_files "linux-headers-pkg.tar.gz" "${TOOLCHAIN_BUILD_DIR}"
fi

echo "[*] Installing Linux API headers..."
tar xf "${TOOLCHAIN_BUILD_DIR}/linux-headers-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"

################################################################################
##
##  Building binutils.
##

if [ ! -e "${TOOLCHAIN_BUILD_DIR}/binutils-pkg.tar.gz" ]; then
    echo "[*] Building Binutils..."
    mkdir -p "${TOOLCHAIN_BUILD_DIR}/binutils"
    cd "${TOOLCHAIN_BUILD_DIR}/binutils"

    download_file binutils.tar.gz "${BINUTILS_URL}" "${BINUTILS_SHA256}"
    rm -rf "binutils-${BINUTILS_VERSION}"
    tar xf binutils.tar.gz
    cd "binutils-${BINUTILS_VERSION}"

    for p in "${SCRIPT_DIR}"/binutils/*.patch; do
        sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "${p}" | \
            sed "s%\@TERMUX_HOME\@%${TERMUX_HOME}%g" | \
                patch --silent -p1
    done
    unset p

    mkdir build
    cd build

    _arch_configure=""
    if [ "${TERMUX_ARCH}" = "x86_64" ]; then
        _arch_configure="--enable-targets=x86_64-pep"
    fi
    ../configure \
        --build="${TERMUX_CHOST}" \
        --host="${TERMUX_CHOST}" \
        --target="${TERMUX_CTARGET}" \
        --with-sysroot="${TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}" \
        --prefix="${TOOLCHAIN_PREFIX}" \
        --mandir="${TOOLCHAIN_PREFIX}/share/man" \
        --infodir="${TOOLCHAIN_PREFIX}/share/info" \
        --disable-multilib \
        --enable-ld=default \
        --enable-gold=yes \
        --enable-64-bit-bfd \
        --enable-plugins \
        --enable-relro \
        --enable-deterministic-archives \
        --disable-install-libiberty \
        ${_arch_configure} \
        --enable-default-hash-style=gnu \
        --with-pic \
        --disable-werror \
        --disable-nls \
        --with-system-zlib
    unset _arch_configure

    make -j "${TOOLCHAIN_BUILD_MAKE_JOBS}"
    make install DESTDIR="${TOOLCHAIN_OUTPUT_DIR}"
    store_built_files "binutils-pkg.tar.gz" "${TOOLCHAIN_OUTPUT_DIR}/${TOOLCHAIN_BASE_DIR}"
fi

echo "[*] Installing Binutils..."
tar xf "${TOOLCHAIN_BUILD_DIR}/binutils-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"

################################################################################
##
##  Building GCC (bootstrap).
##

if [ ! -e "${TOOLCHAIN_BUILD_DIR}/gcc-bootstrap-pkg.tar.gz" ]; then
    echo "[*] Building GCC (bootstrap)..."
    mkdir -p "${TOOLCHAIN_BUILD_DIR}/gcc"
    cd "${TOOLCHAIN_BUILD_DIR}/gcc"

    download_file gcc.tar.xz "${GCC_URL}" "${GCC_SHA256}"
    rm -rf "gcc-${GCC_VERSION}"
    tar xf gcc.tar.xz
    cd "gcc-${GCC_VERSION}"

    for p in "${SCRIPT_DIR}"/gcc/*.patch; do
        sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "${p}" | \
            sed "s%\@TERMUX_HOME\@%${TERMUX_HOME}%g" | \
                patch --silent -p1
    done
    unset p

    mkdir build
    cd build

    export libat_cv_have_ifunc=no
    _arch_configure=""
    if [ "${TERMUX_ARCH}" = "aarch64" ]; then
        _arch_configure="--with-arch=armv8-a --with-abi=lp64"
    elif [ "${TERMUX_ARCH}" = "arm" ]; then
        _arch_configure="--with-arch=armv7-a --with-tune=generic-armv7-a --with-fpu=vfp --with-float=hard --with-abi=aapcs-linux --with-mode=thumb"
    elif [ "${TERMUX_ARCH}" = "i686" ]; then
        _arch_configure="--with-arch=i686 --with-tune=generic --enable-cld"
    elif [ "${TERMUX_ARCH}" = "x86_64" ]; then
        ## Architecture is same as on host.
        _arch_configure=""
    fi

    ../configure \
        --prefix="${TOOLCHAIN_PREFIX}" \
        --build="${TERMUX_CHOST}" \
        --host="${TERMUX_CHOST}" \
        --target="${TERMUX_CTARGET}" \
        --with-pkgversion="Termux ${GCC_VERSION}" \
        --enable-checking=release \
        --enable-clocale=generic \
        --disable-fixed-point \
        --disable-libstdcxx-pch \
        --disable-multilib \
        --disable-nls \
        --disable-werror \
        --disable-symvers \
        --enable-__cxa_atexit \
        --enable-default-pie \
        --enable-cloog-backend \
        --enable-languages=c \
        ${_arch_configure} \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libmpx \
        --disable-libmudflap \
        --disable-libsanitizer \
        --disable-bootstrap \
        --with-sysroot="${TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}" \
        --disable-libgomp \
        --disable-libatomic \
        --disable-libitm \
        --disable-threads \
        --disable-shared \
        --with-newlib \
        --with-system-zlib \
        --with-linker-hash-style=gnu
    unset _arch_configure

    make -j "${TOOLCHAIN_BUILD_MAKE_JOBS}"
    make -j1 install DESTDIR="${TOOLCHAIN_OUTPUT_DIR}"
    store_built_files "gcc-bootstrap-pkg.tar.gz" "${TOOLCHAIN_OUTPUT_DIR}/${TOOLCHAIN_BASE_DIR}"
fi

echo "[*] Installing GCC (bootstrap)..."
tar xf "${TOOLCHAIN_BUILD_DIR}/gcc-bootstrap-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"

################################################################################
##
##  Building Musl libc.
##

if [ ! -e "${TOOLCHAIN_BUILD_DIR}/musl-pkg.tar.gz" ]; then
    echo "[*] Building Musl libc..."
    mkdir -p "${TOOLCHAIN_BUILD_DIR}/musl"
    cd "${TOOLCHAIN_BUILD_DIR}/musl"

    download_file musl.tar.gz "${MUSL_LIBC_URL}" "${MUSL_LIBC_SHA256}"
    rm -rf "musl-${MUSL_LIBC_VERSION}"
    tar xf musl.tar.gz
    cd "musl-${MUSL_LIBC_VERSION}"

    for p in "${SCRIPT_DIR}"/musl/*.patch; do
        sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "${p}" | \
            sed "s%\@TERMUX_HOME\@%${TERMUX_HOME}%g" | \
                patch --silent -p1
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
    make install DESTDIR="${TOOLCHAIN_BUILD_DIR}/musl-install"

    rm -rf "${TOOLCHAIN_OUTPUT_DIR}"
    mkdir -p "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}"
    mv "${TOOLCHAIN_BUILD_DIR}/musl-install/${TERMUX_PREFIX}"/* "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}"/
    rm -rf "${TOOLCHAIN_BUILD_DIR}/musl-install"

    ## Create libssp_nonshared.a used by GCC.
cat << EOF > __stack_chk_fail_local.c
extern void __stack_chk_fail(void);
void __attribute__((visibility ("hidden"))) __stack_chk_fail_local(void) { __stack_chk_fail(); }
EOF
    ${TERMUX_CTARGET}-gcc -c __stack_chk_fail_local.c
    ar -r libssp_nonshared.a __stack_chk_fail_local.o
    mv libssp_nonshared.a "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/libssp_nonshared.a"

    _LDSO=$(make -f Makefile --eval "$(echo -e 'print-ldso:\n\t@echo $$(basename $(LDSO_PATHNAME))')" print-ldso)
    rm -f "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/${_LDSO}"
    mv -f "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/libc.so"    "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/${_LDSO}"
    ln -sfr "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/${_LDSO}" "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/libc.musl-${TERMUX_ARCH}.so.1"
    ln -sfr "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/${_LDSO}" "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/lib/libc.so"
    unset _LDSO

    ## This will be needed when building final GCC.
    ln -sfv . "${TOOLCHAIN_OUTPUT_DIR}/${TERMUX_CTARGET}/usr"

    store_built_files "musl-pkg.tar.gz" "${TOOLCHAIN_BUILD_DIR}"
fi

echo "[*] Installing Musl libc..."
tar xf "${TOOLCHAIN_BUILD_DIR}/musl-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"

################################################################################
##
##  Building final toolchain.
##

if [ ! -e "${TOOLCHAIN_BUILD_DIR}/gcc-final-pkg.tar.gz" ]; then
    echo "[*] Building GCC (final)..."
    mkdir -p "${TOOLCHAIN_BUILD_DIR}/gcc"
    cd "${TOOLCHAIN_BUILD_DIR}/gcc"

    download_file gcc.tar.xz "${GCC_URL}" "${GCC_SHA256}"
    rm -rf "gcc-${GCC_VERSION}"
    tar xf gcc.tar.xz
    cd "gcc-${GCC_VERSION}"

    for p in "${SCRIPT_DIR}"/gcc/*.patch; do
        sed "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" "${p}" | \
            sed "s%\@TERMUX_HOME\@%${TERMUX_HOME}%g" | \
                patch --silent -p1 -F3
    done
    unset p

    mkdir build
    cd build

    export libat_cv_have_ifunc=no
    _arch_configure=""
    if [ "${TERMUX_ARCH}" = "aarch64" ]; then
        _arch_configure="--with-arch=armv8-a --with-abi=lp64"
    elif [ "${TERMUX_ARCH}" = "arm" ]; then
        _arch_configure="--with-arch=armv7-a --with-tune=generic-armv7-a --with-fpu=vfp --with-float=hard --with-abi=aapcs-linux --with-mode=thumb"
    elif [ "${TERMUX_ARCH}" = "i686" ]; then
        _arch_configure="--with-arch=i686 --with-tune=generic --enable-cld"
    elif [ "${TERMUX_ARCH}" = "x86_64" ]; then
        _arch_configure=""
    fi

    ../configure \
        --prefix="${TOOLCHAIN_PREFIX}" \
        --build="${TERMUX_CHOST}" \
        --host="${TERMUX_CHOST}" \
        --target="${TERMUX_CTARGET}" \
        --with-pkgversion="Termux ${GCC_VERSION}" \
        --enable-checking=release \
        --enable-clocale=generic \
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
        ${_arch_configure} \
        --disable-libquadmath \
        --disable-libssp \
        --disable-libmpx \
        --disable-libmudflap \
        --disable-libsanitizer \
        --disable-bootstrap \
        --with-sysroot="${TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}" \
        --disable-libgomp \
        --disable-libatomic \
        --disable-libitm \
        --enable-threads \
        --enable-shared \
        --enable-tls \
        --with-system-zlib \
        --with-linker-hash-style=gnu
    unset _arch_configure

    make -j "${TOOLCHAIN_BUILD_MAKE_JOBS}"
    make -j1 install DESTDIR="${TOOLCHAIN_OUTPUT_DIR}"
    store_built_files "gcc-final-pkg.tar.gz" "${TOOLCHAIN_OUTPUT_DIR}/${TOOLCHAIN_BASE_DIR}"
fi

################################################################################
##
##  Installing complete toolchain.
##

echo "[*] Installing bootstrap toolchain..."
rm -rf "${TOOLCHAIN_PREFIX}"
tar xf "${TOOLCHAIN_BUILD_DIR}/linux-headers-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"
tar xf "${TOOLCHAIN_BUILD_DIR}/binutils-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"
tar xf "${TOOLCHAIN_BUILD_DIR}/musl-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"
tar xf "${TOOLCHAIN_BUILD_DIR}/gcc-final-pkg.tar.gz" -C "${TOOLCHAIN_BASE_DIR}"
rm -rf "${TOOLCHAIN_BUILD_DIR}"

echo "[*] Stripping toolchain binaries..."
scanelf -R "${TOOLCHAIN_PREFIX}" | grep -P 'ET_(EXEC|DYN)' | awk '{ print $2 }' | xargs -r file | grep x86-64 | cut -d: -f1 | xargs -r strip --strip-unneeded

echo "[*] Finished. Check directory '${TOOLCHAIN_PREFIX}'."
