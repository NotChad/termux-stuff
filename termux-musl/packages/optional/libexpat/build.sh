TERMUX_PKG_HOMEPAGE=https://libexpat.github.io/
TERMUX_PKG_DESCRIPTION="XML parsing C library"
TERMUX_PKG_VERSION=2.2.6
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/libexpat/libexpat/releases/download/R_${TERMUX_PKG_VERSION//./_}/expat-$TERMUX_PKG_VERSION.tar.bz2
TERMUX_PKG_SHA256=17b43c2716d521369f82fc2dc70f359860e90fa440bea65b3b85f0b246ea81f2
TERMUX_PKG_DEPENDS="libgcc, musl"
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--without-xmlwf --without-docbook"
