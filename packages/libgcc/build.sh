TERMUX_PKG_HOMEPAGE=http://gcc.gnu.org
TERMUX_PKG_DESCRIPTION="The GNU C compiler runtime library"
TERMUX_PKG_VERSION=6.4.0
TERMUX_PKG_DEPENDS="musl"

termux_step_make_install() {
    cp -f "/opt/termux/toolchain-${TERMUX_ARCH}/${TERMUX_HOST_PLATFORM}/lib/"libgcc_s.so.* \
        "${TERMUX_PREFIX}/lib/"
}
