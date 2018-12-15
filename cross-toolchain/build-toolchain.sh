#!/bin/sh
set -e -u

PKG_ROOT_DIR=$(dirname "$(realpath "${0}")")
. "${PKG_ROOT_DIR}/../scripts/envsetup.sh"

## Building cross-compiler parts.
echo "[*] Building Linux headers..."
sh "${PKG_ROOT_DIR}/01-kernel-headers.sh"
echo "[*] Building Binutils..."
sh "${PKG_ROOT_DIR}/02-binutils.sh"

## Installing all parts of the toolchain.
rm -rf "${CROSS_TOOLCHAIN_PREFIX}" && mkdir "${CROSS_TOOLCHAIN_PREFIX}"
echo "[*] Installing Linux headers..."
tar xf "${TERMUX_OUTPUT_DIR}/linux-headers.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"
echo "[*] Installing Binutils..."
tar xf "${TERMUX_OUTPUT_DIR}/binutils-cross.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"
rm -rf "${TERMUX_BUILD_DIR}"
echo "[*] Done. Check directory '${CROSS_TOOLCHAIN_PREFIX}'."
