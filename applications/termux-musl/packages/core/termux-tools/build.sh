TERMUX_PKG_HOMEPAGE=https://termux.com/
TERMUX_PKG_DESCRIPTION="Basic system tools for Termux"
TERMUX_PKG_ESSENTIAL=yes
TERMUX_PKG_VERSION=0.59
TERMUX_PKG_REVISION=2
TERMUX_PKG_PLATFORM_INDEPENDENT=yes
TERMUX_PKG_DEPENDS="termux-am"
TERMUX_PKG_CONFLICTS="bash (<< 4.4.23-3)"
TERMUX_PKG_CONFFILES="etc/motd"

termux_step_make_install () {
	mkdir -p $TERMUX_PREFIX/bin/applets
	# Remove LD_LIBRARY_PATH from environment to avoid conflicting
	# with system libraries that system binaries may link against:
	for tool in df getprop logcat ping ping6 ip pm settings top; do
		WRAPPER_FILE=$TERMUX_PREFIX/bin/$tool
		echo '#!/bin/sh' > $WRAPPER_FILE
		echo 'unset LD_LIBRARY_PATH LD_PRELOAD' >> $WRAPPER_FILE
		# Some tools require having /system/bin/app_process in the PATH,
		# at least am&pm on a Nexus 6p running Android 6.0:
		echo -n 'PATH=$PATH:/system/bin ' >> $WRAPPER_FILE
		echo "exec /system/bin/$tool \"\$@\"" >> $WRAPPER_FILE
		chmod +x $WRAPPER_FILE
	done

	cp -p $TERMUX_PKG_BUILDER_DIR/{dalvikvm,su,termux-fix-shebang,termux-reload-settings,termux-setup-storage,chsh,termux-open-url,termux-wake-lock,termux-wake-unlock,login,pkg,termux-open,termux-info} $TERMUX_PREFIX/bin/
	perl -p -i -e "s%\@TERMUX_PREFIX\@%${TERMUX_PREFIX}%g" $TERMUX_PREFIX/bin/dalvikvm

	cp $TERMUX_PKG_BUILDER_DIR/motd $TERMUX_PREFIX/etc/motd
	cd $TERMUX_PREFIX/bin
	ln -s -f termux-open xdg-open
}
