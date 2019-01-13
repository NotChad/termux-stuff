TERMUX_PKG_HOMEPAGE=https://www.gnu.org/software/tar/
TERMUX_PKG_DESCRIPTION="GNU tar for manipulating tar archives"
TERMUX_PKG_VERSION=1.31
TERMUX_PKG_SRCURL=https://mirrors.kernel.org/gnu/tar/tar-$TERMUX_PKG_VERSION.tar.xz
TERMUX_PKG_SHA256=37f3ef1ceebd8b7e1ebf5b8cc6c65bb8ebf002c7d049032bf456860f25ec2dc1
TERMUX_PKG_DEPENDS="musl"
TERMUX_PKG_RECOMMENDS="xz-utils"

# When cross-compiling configure guesses that d_ino in struct dirent only exists
# if triplet matches linux*-gnu*, so we force set it explicitly:
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="gl_cv_struct_dirent_d_ino=yes"
