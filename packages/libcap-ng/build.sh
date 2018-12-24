TERMUX_PKG_HOMEPAGE=http://people.redhat.com/sgrubb/libcap-ng/
TERMUX_PKG_DESCRIPTION="Library making programming with POSIX capabilities easier than traditional libcap"
TERMUX_PKG_VERSION=0.7.9
TERMUX_PKG_SRCURL=https://github.com/stevegrubb/libcap-ng/archive/v$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=dc4ef763d3a762e8824081384d20d4f959dbeef3b97e0cc8b78a2b46700dcbe8
TERMUX_PKG_BUILD_IN_SRC=true

termux_step_pre_configure() {
    autoreconf -fvi
}
