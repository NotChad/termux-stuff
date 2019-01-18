#!/data/data/com.termux/files/usr/bin/bash
set -e

PREFIX="/data/data/com.termux/files/usr"
HOME="/data/data/com.termux/files/home"
TMPDIR="${PREFIX}/tmp"
export HOME TMPDIR

TERMUX_BUILDER_ROOTFS_URL="https://github.com/xeffyr/termux-stuff/releases/download/base/termux-builder-rootfs.tar.gz"
TERMUX_BUILDER_ROOTFS_FILE="${TMPDIR}/termux-builder-rootfs.tar.gz"
TERMUX_BUILDER_ROOTFS_SHA256="748cbecea10b1376022c4eada81417b0dc6ae98a68cf13a3d18c708e5494b76e"
TERMUX_BUILDER_ROOTFS_DIR="${HOME}/.termux-builder"

if [ -e "${TERMUX_BUILDER_ROOTFS_DIR}/.installed" ]; then
    echo "[@] Termux Builder already installed, do you want to"
    echo -n "    reinstall it ? (y/n): "
    read -r CHOICE
    if [[ "${CHOICE}" = [Yy] ]]; then
        echo "[*] Deleting previous installation..."
        rm -rf "${TERMUX_BUILDER_ROOTFS_DIR}"
    else
        exit 0
    fi
fi

## Ensure that these directories exist.
mkdir -p "${TMPDIR}" "${HOME}" "${TERMUX_BUILDER_ROOTFS_DIR}"

## Install necessary packages.
echo "[*] Installing necessary packages, if needed..."
apt update
apt upgrade -y
apt install -y bzip2 curl proot tar x11-repo

## QEMU should be installed separately since it is located
## in x11-repo.
apt install -y qemu-user-x86_64

## Downloading rootfs (if needed).
if [ -e "${TERMUX_BUILDER_ROOTFS_FILE}" ]; then
    echo -n "[*] Checking SHA-256 of existing file... "
    if ! echo "${TERMUX_BUILDER_ROOTFS_SHA256}  ${TERMUX_BUILDER_ROOTFS_FILE}" | sha256sum -c >/dev/null 2>&1; then
        echo "fail"
        rm -f "${TERMUX_BUILDER_ROOTFS_FILE}"
    else
        echo
    fi
fi

if [ ! -e "${TERMUX_BUILDER_ROOTFS_FILE}" ]; then
    echo "[*] Downloading Termux Builder rootfs (Ubuntu)..."
    curl -L -o "${TERMUX_BUILDER_ROOTFS_FILE}" "${TERMUX_BUILDER_ROOTFS_URL}"

    echo -n "[*] Checking SHA-256 of downloaded file... "
    if ! echo "${TERMUX_BUILDER_ROOTFS_SHA256}  ${TERMUX_BUILDER_ROOTFS_FILE}" | sha256sum -c >/dev/null 2>&1; then
        echo "fail"
        exit 1
    else
        echo
    fi
fi

## Unpacking rootfs.
echo "[*] Unpacking rootfs (may take long time)..."
tar xf "${TERMUX_BUILDER_ROOTFS_FILE}" -C "${TERMUX_BUILDER_ROOTFS_DIR}"

## Delete rootfs archive to free space.
rm -f "${TERMUX_BUILDER_ROOTFS_FILE}"

## Installing script.
echo "[*] Finising..."
cp ./termux-builder.sh "${PREFIX}/bin/termux-builder"
chmod 700 "${PREFIX}/bin/termux-builder"
ln -sf "${PREFIX}/bin/termux-builder" "${HOME}/start-termux-builder.sh"
echo "[ -d \"\${HOME}/termux-packages\" ] && cd \${HOME}/termux-packages" > "${TERMUX_BUILDER_ROOTFS_DIR}/home/builder/.bashrc"
touch "${TERMUX_BUILDER_ROOTFS_DIR}/home/builder/.hushlogin"
touch "${TERMUX_BUILDER_ROOTFS_DIR}/.installed"
echo "[*] Done. Now execute command 'termux-builder'."
