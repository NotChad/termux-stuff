TERMUX_PKG_HOMEPAGE=https://www.gnupg.org/related_software/libgpg-error/
TERMUX_PKG_DESCRIPTION="Small library that defines common error values for all GnuPG components"
TERMUX_PKG_VERSION=1.30
TERMUX_PKG_REVISION=1
TERMUX_PKG_SRCURL=https://www.gnupg.org/ftp/gcrypt/libgpg-error/libgpg-error-$TERMUX_PKG_VERSION.tar.bz2
TERMUX_PKG_SHA256=238c6e87adf52b0147081927c981730756a0526ad0733201142a676786847ed7
TERMUX_PKG_DEPENDS="musl"
TERMUX_PKG_RM_AFTER_INSTALL="share/common-lisp"
TERMUX_PKG_BUILD_IN_SRC=true

TERMUX_PKG_INCLUDE_IN_DEVPACKAGE="
bin/gpg-error-config
share/man/man1/gpg-error-config.1
"

termux_step_pre_configure() {
    if [ "${TERMUX_ARCH}" = "arm" ]; then
        ln -sf lock-obj-pub.x86_64-pc-linux-musl.h \
            src/syscfg/lock-obj-pub.linux-musleabihf.h
    else
        ln -sf lock-obj-pub.x86_64-pc-linux-musl.h \
            src/syscfg/lock-obj-pub.linux-musl.h
    fi
}
