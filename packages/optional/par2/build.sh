TERMUX_PKG_HOMEPAGE=https://github.com/Parchive/par2cmdline
TERMUX_PKG_DESCRIPTION="PAR 2.0 compatible file verification and repair tool."
TERMUX_PKG_VERSION=0.8.0
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://github.com/Parchive/par2cmdline/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=461b45627a0d800061657b2d800c432c7d1c86c859b40a3ced35a0cc6a85faca
TERMUX_PKG_DEPENDS="libgcc, libstdc++, musl"
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_pre_configure() {
	aclocal
	automake --add-missing
	autoconf
}
