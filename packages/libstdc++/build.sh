TERMUX_PKG_HOMEPAGE=http://gcc.gnu.org
TERMUX_PKG_DESCRIPTION="The standard C++ library"
TERMUX_PKG_VERSION=6.4.0
TERMUX_PKG_DEPENDS="libgcc, musl"

TERMUX_PKG_RM_AFTER_INSTALL="lib/libstdc++.so.6.0.22-gdb.py"

termux_step_make_install() {
    cp -f "/opt/termux/toolchain-$TERMUX_ARCH/$TERMUX_HOST_PLATFORM/lib/"libstdc++.so.* \
        "$TERMUX_PREFIX/lib/"
}
