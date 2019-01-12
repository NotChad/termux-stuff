TERMUX_PKG_HOMEPAGE=http://invisible-island.net/dialog/
TERMUX_PKG_DESCRIPTION="Application used in shell scripts which displays text user interface widgets"
TERMUX_PKG_VERSION="1.3-20181107"
TERMUX_PKG_SRCURL=https://invisible-mirror.net/archives/dialog/dialog-$TERMUX_PKG_VERSION.tgz
TERMUX_PKG_SHA256=efeaca8027dda53a9f3cf6c7b5c1a77093825b7a9b85c23c0c6c96afc3506457
TERMUX_PKG_DEPENDS="musl, ncurses"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--with-ncursesw
--enable-widec
--with-pkg-config
"

termux_step_pre_configure() {
	# Put a temporary link for libtinfo.so
	ln -s -f $TERMUX_PREFIX/lib/libncursesw.so $TERMUX_PREFIX/lib/libtinfo.so
}

termux_step_post_make_install() {
	rm $TERMUX_PREFIX/lib/libtinfo.so
	cd $TERMUX_PREFIX/bin
	ln -f -s dialog whiptail
}
