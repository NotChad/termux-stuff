#!/bin/sh
# clean.sh - clean everything.
set -e -u

: ${TERMUX_TOPDIR:="$HOME/.termux-build"}
rm -Rf /data/* $TERMUX_TOPDIR
