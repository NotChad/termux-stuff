TERMUX_PKG_HOMEPAGE=http://zlib.net
TERMUX_PKG_DESCRIPTION="A compression/decompression Library"
TERMUX_PKG_VERSION=1.2.11
TERMUX_PKG_SRCURL=http://zlib.net/zlib-${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=c3e5e9fdd5004dcb542feda5ee4f0ff0744628baf8ed2dd5d66f8ca1197cb1a1
TERMUX_PKG_DEPENDS="musl"
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_configure() {
    CHOST="${TERMUX_HOST_PLATFORM}" ./configure \
        --prefix=$TERMUX_PREFIX \
        --libdir=$TERMUX_PREFIX/lib \
        --shared
}
