#####################################################################
##
##  CONFIGURABLE PARAMS
##
#####################################################################

TERMUX_ARCH="aarch64"
TERMUX_CHOST="x86_64-cross-linux-musl"
TERMUX_CTARGET="aarch64-unknown-linux-musl"

#####################################################################

: "${TERMUX_BUILD_DIR:="${HOME}/.builddir"}"
: "${TERMUX_OUTPUT_DIR:="${HOME}/builder-output"}"
: "${TERMUX_SOURCE_CACHE_DIR:="${HOME}/source-cache"}"
CROSS_TOOLCHAIN_PREFIX="/opt/termux/${TERMUX_CTARGET}"
TERMUX_PREFIX="/data/data/com.termux/files/usr"

mkdir -p "${TERMUX_PREFIX}"
mkdir -p "${TERMUX_BUILD_DIR}"
mkdir -p "${TERMUX_OUTPUT_DIR}"
mkdir -p "${TERMUX_SOURCE_CACHE_DIR}"

## Add our cross-compiler to the PATH.
export PATH="${PATH}:${CROSS_TOOLCHAIN_PREFIX}/bin"

## CPP fix: some configure scripts search for 'cpp' in /lib but
## Alpine Linux doesn't provide /lib/cpp. Only /usr/bin/cpp.
export CPP="/usr/bin/cpp"
