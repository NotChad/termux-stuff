TERMUX_PKG_HOMEPAGE=https://kernel.org
TERMUX_PKG_DESCRIPTION="Linux kernel API headers"
TERMUX_PKG_VERSION=3.16.61
TERMUX_PKG_SRCURL=https://cdn.kernel.org/pub/linux/kernel/v3.x/linux-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=42d5f6c46d9e4b1dbff04344fef441b219067753dc519c689106fab7e4444d4c
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_NO_DEVELSPLIT=true

termux_step_make() {
    if [ "$TERMUX_ARCH" = "aarch64" ]; then
        _TERMUX_ARCH="arm64"
    elif [ "$TERMUX_ARCH" = "i686" ]; then
        _TERMUX_ARCH="x86"
    else
        _TERMUX_ARCH="$TERMUX_ARCH"
    fi

    make mrproper
    make ARCH="${_TERMUX_ARCH}" headers_check
}

termux_step_make_install() {
    make mrproper
    make ARCH="${_TERMUX_ARCH}" INSTALL_HDR_PATH="$TERMUX_PREFIX" headers_install
}

termux_step_post_massage() {
    cd "$TERMUX_PKG_MASSAGEDIR/$TERMUX_PREFIX"
    find . -type f -iname ".install" -delete
    find . -type f -iname "..install.cmd" -delete
}
