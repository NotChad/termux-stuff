#!/bin/sh
set -e -u

PKG_ROOT_DIR=$(dirname "$(realpath "${0}")")
. "${PKG_ROOT_DIR}/../scripts/envsetup.sh"

## Remove old toolchain.
rm -rf "${CROSS_TOOLCHAIN_PREFIX}" && mkdir "${CROSS_TOOLCHAIN_PREFIX}"

## Install Linux headers.
echo "[*] Building Linux headers..."
sh "${PKG_ROOT_DIR}/01-kernel-headers.sh"
echo "[*] Installing Linux headers..."
tar xf "${TERMUX_OUTPUT_DIR}/linux-headers.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"

## Install binutils.
echo "[*] Building Binutils..."
sh "${PKG_ROOT_DIR}/02-binutils.sh"
echo "[*] Installing Binutils..."
tar xf "${TERMUX_OUTPUT_DIR}/binutils-cross.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"

## Install GCC (bootstrap).
echo "[*] Building GCC (bootstrap)..."
sh "${PKG_ROOT_DIR}/03-gcc-bootstrap.sh"
echo "[*] Installing GCC (bootstrap)..."
tar xf "${TERMUX_OUTPUT_DIR}/gcc-bootstrap-cross.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"

## Install Musl libc.
echo "[*] Building Musl libc..."
sh "${PKG_ROOT_DIR}/04-musl-libc.sh"
echo "[*] Installing Musl libc..."
tar xf "${TERMUX_OUTPUT_DIR}/musl-libc.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}"

## Build GCC (final).
echo "[*] Building GCC (finalizing)..."
sh "${PKG_ROOT_DIR}/05-gcc-final.sh"
rm -rf "${CROSS_TOOLCHAIN_PREFIX}" && mkdir "${CROSS_TOOLCHAIN_PREFIX}"
tar xf "${TERMUX_OUTPUT_DIR}/linux-headers.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"
tar xf "${TERMUX_OUTPUT_DIR}/binutils-cross.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"
tar xf "${TERMUX_OUTPUT_DIR}/musl-libc.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}/${TERMUX_CTARGET}"
tar xf "${TERMUX_OUTPUT_DIR}/gcc-final-cross.tar.gz" -C "${CROSS_TOOLCHAIN_PREFIX}"
echo "[*] Done. Check directory '${CROSS_TOOLCHAIN_PREFIX}'."
