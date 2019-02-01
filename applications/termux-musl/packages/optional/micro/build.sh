TERMUX_PKG_HOMEPAGE=https://micro-editor.github.io/
TERMUX_PKG_DESCRIPTION="Modern and intuitive terminal-based text editor"
TERMUX_PKG_VERSION=1.4.1
TERMUX_PKG_REVISION=3
TERMUX_PKG_SRCURL=https://github.com/zyedidia/micro/releases/download/v$TERMUX_PKG_VERSION/micro-$TERMUX_PKG_VERSION-src.tar.gz
TERMUX_PKG_SHA256=0b516826226cf1ddf2fbb274f049cab456a5c162efe3d648f0871564fadcf812
TERMUX_PKG_DEPENDS="musl"

termux_step_make() {
	return
}

termux_step_make_install() {
	termux_setup_golang

	export GOPATH=$TERMUX_PKG_BUILDDIR
	local MICRO_SRC=$GOPATH/src/github.com/zyedidia/micro

	cd $TERMUX_PKG_SRCDIR
	mkdir -p $MICRO_SRC
	cp -R . $MICRO_SRC

	cd $MICRO_SRC
	make build-quick
	mv micro $TERMUX_PREFIX/bin/micro
}
