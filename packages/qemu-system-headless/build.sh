TERMUX_PKG_MAINTAINER="Leonid Plyushch <leonid.plyushch@gmail.com> @xeffyr"

TERMUX_PKG_HOMEPAGE=https://www.qemu.org
TERMUX_PKG_DESCRIPTION="A generic and open source machine emulator (x86_64)"
TERMUX_PKG_VERSION=3.1.0
TERMUX_PKG_SRCURL=https://download.qemu.org/qemu-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=6a0508df079a0a33c2487ca936a56c12122f105b8a96a44374704bef6c69abfc
TERMUX_PKG_DEPENDS="attr, glib, libbz2, libcap, libgcc, liblzo, ncurses, libpixman, libstdc++, musl, qemu-common, zlib"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_RM_AFTER_INSTALL="
bin/qemu-nbd
share/man/man8
"

termux_step_configure() {
    local ENABLED_TARGETS="aarch64-softmmu,arm-softmmu,i386-softmmu,x86_64-softmmu,aarch64-linux-user,arm-linux-user,i386-linux-user,x86_64-linux-user"

    ./configure --prefix="$TERMUX_PREFIX" \
                --cross-prefix="${TERMUX_HOST_PLATFORM}-" \
                --cc="$CC" \
                --host-cc="gcc" \
                --cxx="$CXX" \
                --objcc="$CC" \
                --extra-cflags="$CFLAGS -I$TERMUX_PREFIX/include" \
                --extra-cxxflags="$CXXFLAGS -I$TERMUX_PREFIX/include" \
                --extra-ldflags="$LDFLAGS" \
                --interp-prefix="$TERMUX_PREFIX/gnemul" \
                --python="/usr/bin/python3" \
                --smbd="$TERMUX_PREFIX/bin/smbd" \
                --enable-curses \
                --enable-vnc \
                --enable-bzip2 \
                --enable-lzo \
                --enable-coroutine-pool \
                --enable-virtfs \
                --disable-hax \
                --disable-kvm \
                --disable-xen \
                --disable-guest-agent \
                --disable-stack-protector \
                --target-list="${ENABLED_TARGETS}"
}

termux_step_post_make_install() {
    ## by default, alias 'qemu' will be a qemu-system-x86_64
    ln -sfr "${TERMUX_PREFIX}/bin/qemu-system-x86_64" "${TERMUX_PREFIX}/bin/qemu"
    sed -i 's/qemu\\-system\\-i386/qemu\\-system\\-x86_64/g' "${TERMUX_PREFIX}/share/man/man1/qemu.1"

    ## symlink manpages
    ln -sfr "${TERMUX_PREFIX}/share/man/man1/qemu.1" "${TERMUX_PREFIX}/share/man/man1/qemu-system-aarch64.1"
    ln -sfr "${TERMUX_PREFIX}/share/man/man1/qemu.1" "${TERMUX_PREFIX}/share/man/man1/qemu-system-arm.1"
    ln -sfr "${TERMUX_PREFIX}/share/man/man1/qemu.1" "${TERMUX_PREFIX}/share/man/man1/qemu-system-i386.1"
    ln -sfr "${TERMUX_PREFIX}/share/man/man1/qemu.1" "${TERMUX_PREFIX}/share/man/man1/qemu-system-x86_64.1"
}
