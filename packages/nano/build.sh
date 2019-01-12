TERMUX_PKG_HOMEPAGE=https://www.nano-editor.org/
TERMUX_PKG_DESCRIPTION="Small, free and friendly text editor"
TERMUX_PKG_VERSION=3.2
TERMUX_PKG_SRCURL=https://nano-editor.org/dist/latest/nano-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=d12773af3589994b2e4982c5792b07c6240da5b86c5aef2103ab13b401fe6349
TERMUX_PKG_DEPENDS="musl, ncurses"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
ac_cv_header_pwd_h=no
--disable-libmagic
--enable-utf8
--with-wordbounds
"

TERMUX_PKG_RM_AFTER_INSTALL="
bin/rnano
share/man/man1/rnano.1
share/nano/man-html
"

termux_step_post_make_install () {
	# Configure nano to use syntax highlighting:
	echo include \"$TERMUX_PREFIX/share/nano/\*nanorc\" > $TERMUX_PREFIX/etc/nanorc
}
