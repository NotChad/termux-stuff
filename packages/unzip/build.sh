TERMUX_PKG_HOMEPAGE=http://www.info-zip.org/
TERMUX_PKG_DESCRIPTION="Tools for working with zip files"
TERMUX_PKG_VERSION=6.0
TERMUX_PKG_SRCURL=https://downloads.sourceforge.net/infozip/unzip${TERMUX_PKG_VERSION/./}.tar.gz
TERMUX_PKG_SHA256=036d96991646d0449ed0aa952e4fbe21b476ce994abc276e49d30e686708bd37
TERMUX_PKG_DEPENDS="libbz2, musl"
TERMUX_PKG_BUILD_IN_SRC=yes

termux_step_make() {
	DEFINES='-DACORN_FTYPE_NFS -DWILD_STOP_AT_DIR -DLARGE_FILE_SUPPORT \
			-DUNICODE_SUPPORT -DUNICODE_WCHAR -DUTF8_MAYBE_NATIVE -DNO_LCHMOD \
			-DDATE_FORMAT=DF_YMD -DUSE_BZIP2 -DNOMEMCPY -DNO_WORKING_ISPRINT'

	make -f unix/Makefile prefix=$TERMUX_PREFIX \
			D_USE_BZ2=-DUSE_BZIP2 L_BZ2=-lbz2 \
			CC="$CC" LD="$CC" LF2="$LDFLAGS" CF="$CFLAGS $CPPFLAGS -I. $DEFINES" \
			unzips
}

termux_step_make_install() {
	make -f unix/Makefile prefix="$TERMUX_PREFIX" install
}