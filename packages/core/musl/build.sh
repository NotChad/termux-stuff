TERMUX_PKG_HOMEPAGE=http://www.musl-libc.org/
TERMUX_PKG_DESCRIPTION="The musl c library (libc) implementation"
TERMUX_PKG_ESSENTIAL=true
TERMUX_PKG_VERSION=1.1.20
TERMUX_PKG_SRCURL=http://www.musl-libc.org/releases/musl-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=44be8771d0e6c6b5f82dd15662eb2957c9a3173a19a8b49966ac0542bbd40d61
TERMUX_PKG_BUILD_DEPENDS="linux-api-headers"
TERMUX_PKG_DEVPACKAGE_DEPENDS="linux-api-headers"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_KEEP_STATIC_LIBRARIES=true

TERMUX_PKG_INCLUDE_IN_DEVPACKAGE="
lib/*.a
lib/*.o
"

TERMUX_PKG_CONFFILES="
etc/hosts
etc/resolv.conf
etc/passwd
etc/group
"

## Needed to perform complete installation when rebuilding, otherwise
## only changed files will be packaged.
TERMUX_PKG_EXTRA_MAKE_ARGS="-B"

termux_step_configure() {
	LDFLAGS+=" -Wl,-soname,libc.musl-$TERMUX_ARCH.so.1"
	./configure \
		--build="x86_64-cross-linux-musl" \
		--host="$TERMUX_HOST_PLATFORM" \
		--prefix="$TERMUX_PREFIX" \
		--sysconfdir="$TERMUX_PREFIX/etc" \
		--syslibdir="$TERMUX_PREFIX/lib" \
		--mandir="$TERMUX_PREFIX/share/man" \
		--infodir="$TERMUX_PREFIX/share/info" \
		--localstatedir="$TERMUX_PREFIX/share/var"
}

termux_step_post_make_install() {
	local LDSO="$(make -f Makefile --eval "$(echo -e 'print-ldso:\n\t@echo $$(basename $(LDSO_PATHNAME))')" print-ldso)"
	rm -f "$TERMUX_PREFIX/lib/$LDSO"
	mv -f "$TERMUX_PREFIX/lib/libc.so" "$TERMUX_PREFIX/lib/$LDSO"
	ln -sfr "$TERMUX_PREFIX/lib/$LDSO" "$TERMUX_PREFIX/lib/libc.musl-$TERMUX_ARCH.so.1"
	ln -sfr "$TERMUX_PREFIX/lib/$LDSO" "$TERMUX_PREFIX/lib/libc.so"
	ln -sfr "$TERMUX_PREFIX/lib/$LDSO" "$TERMUX_PREFIX/bin/ldd"

	## Compatibility links.
	for i in libc.so.6 libcrypt.so.1 libm.so.6 libpthread.so.0 librt.so.1 libutil.so.1; do
		ln -sfr "$TERMUX_PREFIX/lib/libc.musl-$TERMUX_ARCH.so.1" "$TERMUX_PREFIX/lib/$i"
	done
	unset i
	if [ "$TERMUX_ARCH" = "aarch64" ]; then
		ln -sfr "$TERMUX_PREFIX/lib/libc.musl-$TERMUX_ARCH.so.1" "$TERMUX_PREFIX/lib/ld-linux-aarch64.so.1"
	fi

	## Create basic /etc/resolv.conf
	{
		echo "nameserver 1.0.0.1"
		echo "nameserver 1.1.1.1"
	} > "$TERMUX_PREFIX/etc/resolv.conf"

	## Create basic /etc/hosts
	echo "127.0.0.1 localhost" > "$TERMUX_PREFIX/etc/hosts"

	## Install user/group database
	sed \
			-e "s|@TERMUX_PREFIX@|$TERMUX_PREFIX|" \
			-e "s|@TERMUX_HOME@|$TERMUX_HOME|" \
			"$TERMUX_PKG_BUILDER_DIR"/configs/passwd > "$TERMUX_PREFIX"/etc/passwd
	install -Dm600 "$TERMUX_PKG_BUILDER_DIR/configs/group" "$TERMUX_PREFIX/etc/group"
}
