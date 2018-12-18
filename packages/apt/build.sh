TERMUX_PKG_HOMEPAGE=https://packages.debian.org/apt
TERMUX_PKG_DESCRIPTION="Front-end for the dpkg package manager"
TERMUX_PKG_ESSENTIAL=yes
TERMUX_PKG_VERSION=1.4.8
TERMUX_PKG_SRCURL=http://ftp.debian.org/debian/pool/main/a/apt/apt_${TERMUX_PKG_VERSION}.tar.xz
TERMUX_PKG_SHA256=767ad7d6efb64cde52faececb7d3c0bf49800b9fe06f3a5b0132ab4c01a5b8f8
TERMUX_PKG_DEPENDS="dpkg, libcurl, liblzma, musl, zlib"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-DPERL_EXECUTABLE=`which perl`
-DCMAKE_INSTALL_FULL_LOCALSTATEDIR=$TERMUX_PREFIX
-DCOMMON_ARCH=$TERMUX_ARCH
-DDPKG_DATADIR=$TERMUX_PREFIX/share/dpkg
-DUSE_NLS=OFF
-DWITH_DOC=OFF
-DCMAKE_INSTALL_LIBEXECDIR=$TERMUX_PREFIX/lib
"

TERMUX_PKG_CONFFILES="etc/apt/sources.list etc/apt/trusted.gpg.d/xeffyr.gpg"

TERMUX_PKG_RM_AFTER_INSTALL="
bin/apt-cdrom
bin/apt-extracttemplates
bin/apt-sortpkgs
etc/apt/apt.conf.d
lib/apt/apt-helper
lib/apt/methods/bzip2
lib/apt/methods/cdrom
lib/apt/methods/mirror
lib/apt/methods/rred
lib/apt/planners/
lib/apt/solvers/
lib/dpkg/
lib/libapt-inst.so
lib/libapt-inst.so.2.0
lib/libapt-inst.so.2.0.0
share/bash-completion
"

termux_step_pre_configure() {
    ## Fix linking error.
    LDFLAGS+=" -lnghttp2 -lssl -lcrypto -llzma -lz"
}

termux_step_post_make_install() {
	printf "# The main termux repository:\ndeb https://xeffyr.ttm.sh/termux/ musl main\n" > $TERMUX_PREFIX/etc/apt/sources.list
    mkdir -p $TERMUX_PREFIX/etc/apt/trusted.gpg.d
	cp $TERMUX_PKG_BUILDER_DIR/xeffyr.gpg $TERMUX_PREFIX/etc/apt/trusted.gpg.d/xeffyr.gpg
	rm $TERMUX_PREFIX/include/apt-pkg -r

	# apt-transport-tor
	ln -sfr $TERMUX_PREFIX/lib/apt/methods/http $TERMUX_PREFIX/lib/apt/methods/tor
	ln -sfr $TERMUX_PREFIX/lib/apt/methods/http $TERMUX_PREFIX/lib/apt/methods/tor+http
	ln -sfr $TERMUX_PREFIX/lib/apt/methods/https $TERMUX_PREFIX/lib/apt/methods/tor+https
}
