TERMUX_PKG_HOMEPAGE=http://savannah.nongnu.org/projects/attr/
TERMUX_PKG_DESCRIPTION="Utilities for manipulating filesystem extended attributes"
TERMUX_PKG_VERSION=2.4.48
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=http://download.savannah.gnu.org/releases/attr/attr-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=5ead72b358ec709ed00bbf7a9eaef1654baad937c001c044fe8b74c57f5324e7
TERMUX_PKG_DEPENDS="musl"
TERMUX_PKG_BUILD_IN_SRC=yes
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="--enable-gettext=no"
# attr.5 man page is in linux-man-pages:
TERMUX_PKG_RM_AFTER_INSTALL="share/man/man5/attr.5"
