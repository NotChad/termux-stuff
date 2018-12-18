TERMUX_PKG_HOMEPAGE=https://busybox.net/
TERMUX_PKG_DESCRIPTION="Tiny versions of many common UNIX utilities into a single small executable"
TERMUX_PKG_ESSENTIAL=yes
TERMUX_PKG_VERSION=1.28.4
TERMUX_PKG_SRCURL=https://busybox.net/downloads/busybox-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=e3c14a3699dc7e82fed397392957afc78e37bdf25398ac38ead6e84621b2ae6a
TERMUX_PKG_DEPENDS="musl"
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_configure () {
    export CROSS_COMPILE="${TERMUX_HOST_PLATFORM}-"
	cp $TERMUX_PKG_BUILDER_DIR/busybox.config .config
    make silentoldconfig
}

termux_step_post_make_install () {
	if [ "$TERMUX_DEBUG" == "true" ]; then
		install busybox_unstripped $PREFIX/bin/busybox
	else
		install -Dm755 busybox "${TERMUX_PREFIX}/bin/busybox"
	fi

	# Create symlinks in $PREFIX/bin/applets to $PREFIX/bin/busybox
	rm -Rf $TERMUX_PREFIX/bin/applets
	mkdir -p $TERMUX_PREFIX/bin/applets
	cd $TERMUX_PREFIX/bin/applets
	for f in `cat $TERMUX_PKG_SRCDIR/busybox.links`; do ln -s ../busybox `basename $f`; done

	# The 'env' applet is special in that it go into $PREFIX/bin:
	cd $TERMUX_PREFIX/bin
	ln -f -s busybox env

	# Install busybox man page
	mkdir -p $TERMUX_PREFIX/share/man/man1
	cp $TERMUX_PKG_SRCDIR/docs/busybox.1 $TERMUX_PREFIX/share/man/man1

	# Needed for 'crontab -e' to work out of the box:
	local _CRONTABS=$TERMUX_PREFIX/var/spool/cron/crontabs
	mkdir -p $_CRONTABS
	echo "Used by the busybox crontab and crond tools" > $_CRONTABS/README.termux
}

