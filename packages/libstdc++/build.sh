TERMUX_PKG_HOMEPAGE=http://gcc.gnu.org
TERMUX_PKG_DESCRIPTION="The standard C++ library"
TERMUX_PKG_VERSION=8.2.0
TERMUX_PKG_DEPENDS="libgcc, musl"
TERMUX_PKG_KEEP_STATIC_LIBRARIES=true

TERMUX_PKG_INCLUDE_IN_DEVPACKAGE="
lib/libstdc++.a
lib/libstdc++fs.a
lib/libsupc++.a
lib/libstdc++.so
lib/libstdc++.so.6.0.25-gdb.py
"

termux_step_make_install() {
	local SYSROOT=$TERMUX_STANDALONE_TOOLCHAIN/$TERMUX_HOST_PLATFORM

	install -Dm700 "$SYSROOT/lib/libstdc++.so.6.0.25" "$TERMUX_PREFIX/lib/libstdc++.so.6.0.25"
	ln -sfr "$TERMUX_PREFIX/lib/libstdc++.so.6.0.25" "$TERMUX_PREFIX/lib/libstdc++.so.6"
	ln -sfr "$TERMUX_PREFIX/lib/libstdc++.so.6.0.25" "$TERMUX_PREFIX/lib/libstdc++.so"

	for lib in libstdc++.a libstdc++fs.a libsupc++.a; do
		install -Dm600 "$SYSROOT/lib/$lib" "$TERMUX_PREFIX/lib/$lib"
		$STRIP --strip-unneeded "$TERMUX_PREFIX/lib/$lib"
	done

	rm -rf "$TERMUX_PREFIX/include/c++"
	cp -a "$SYSROOT/include/c++" "$TERMUX_PREFIX/include/"
}
