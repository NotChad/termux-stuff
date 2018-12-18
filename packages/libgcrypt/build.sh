TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/libgcrypt/
TERMUX_PKG_DESCRIPTION="General purpose cryptographic library based on the code from GnuPG"
TERMUX_PKG_VERSION=1.8.4
TERMUX_PKG_SRCURL=https://www.gnupg.org/ftp/gcrypt/libgcrypt/libgcrypt-${TERMUX_PKG_VERSION}.tar.bz2
TERMUX_PKG_SHA256=f638143a0672628fde0cad745e9b14deb85dffb175709cacc1f4fe24b93f2227
TERMUX_PKG_DEPENDS="libgpg-error, musl"
TERMUX_PKG_DEVPACKAGE_DEPENDS="libgpg-error-dev"

TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
--disable-jent-support
"
