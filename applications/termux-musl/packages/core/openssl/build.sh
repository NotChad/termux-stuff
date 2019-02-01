TERMUX_PKG_HOMEPAGE=https://www.openssl.org/
TERMUX_PKG_DESCRIPTION="Library implementing the SSL and TLS protocols as well as general purpose cryptography functions"
TERMUX_PKG_VERSION=1.1.1a
TERMUX_PKG_SRCURL=https://www.openssl.org/source/openssl-${TERMUX_PKG_VERSION/\~/-}.tar.gz
TERMUX_PKG_SHA256=fc20130f8b7cbd2fb918b2f14e2f429e109c31ddd0fb38fc5d71d9ffed3f9f41
TERMUX_PKG_DEPENDS="ca-certificates, musl"
TERMUX_PKG_RM_AFTER_INSTALL="bin/c_rehash etc/ssl/misc"
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_configure () {
	CFLAGS+=" -DNO_SYSLOG"

	perl -p -i -e "s@TERMUX_CFLAGS@$CFLAGS@g" Configure
	rm -Rf $TERMUX_PREFIX/lib/libcrypto.* $TERMUX_PREFIX/lib/libssl.*
	test $TERMUX_ARCH = "arm" && TERMUX_OPENSSL_PLATFORM="linux-armv4"
	test $TERMUX_ARCH = "aarch64" && TERMUX_OPENSSL_PLATFORM="linux-aarch64"
	test $TERMUX_ARCH = "i686" && TERMUX_OPENSSL_PLATFORM="linux-elf"
	test $TERMUX_ARCH = "x86_64" && TERMUX_OPENSSL_PLATFORM="linux-x86_64"
	# If enabling zlib-dynamic we need "zlib-dynamic" instead of "no-comp no-dso":
	./Configure $TERMUX_OPENSSL_PLATFORM \
		--prefix=$TERMUX_PREFIX \
		--openssldir=$TERMUX_PREFIX/etc/tls \
		shared \
		no-ssl \
		no-comp \
		no-dso \
		no-hw \
		no-srp \
		no-tests
}

termux_step_make () {
	make depend
	make -j $TERMUX_MAKE_PROCESSES all
}

termux_step_make_install () {
	# "install_sw" instead of "install" to not install man pages:
	make -j 1 install_sw MANDIR=$TERMUX_PREFIX/share/man MANSUFFIX=.ssl

	cp apps/openssl.cnf $TERMUX_PREFIX/etc/tls/openssl.cnf
}
