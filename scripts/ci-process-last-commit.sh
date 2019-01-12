#!/bin/bash

SCRIPT_PATH=$(realpath "$0")
SCRIPT_DIR=$(dirname "$SCRIPT_PATH")
REPO_DIR=$(dirname "$SCRIPT_DIR")
cd "$REPO_DIR" || {
    echo "[!] Failed to cd into '$REPO_DIR'."
    exit 1
}

## Check for updated files and determine if they are part of packages.
UPDATED_FILES=$(git diff-tree --no-commit-id --name-only -r HEAD | grep packages/)
if [ -z "$UPDATED_FILES" ]; then
    echo "[*] No packages changed."
    echo "[*] Finishing with status 'OK'."
    exit 0
fi

## Determine package directories.
PACKAGE_DIRS=$(echo "$UPDATED_FILES" | grep -oP "packages/[a-z0-9+.-]+" | sort | uniq)
if [ -z "$PACKAGE_DIRS" ]; then
    echo "[!] Failed to determine updated packages."
    echo "    Perhaps, script failed ?"
    exit 1
fi
for dir in $PACKAGE_DIRS; do
    if [ ! -d "$REPO_DIR/$dir" ]; then
        echo "[!] Nonexistent package directory '$dir'."
        echo "    Perhaps, script failed ?"
        exit 1
    fi
done

## Determine package names.
PACKAGE_NAMES=$(echo "$PACKAGE_DIRS" | xargs -n 1 basename)
if [ -z "$PACKAGE_NAMES" ]; then
    echo "[!] Failed to determine package names."
    echo "    Perhaps, script failed ?"
    exit 1
fi

## Create directory where built packages will be placed.
if ! mkdir -p ./binary-packages > /dev/null 2>&1; then
    echo "[!] Failed to create directory './binary-packages'."
    exit 1
fi

## Build packages for each architecture.
for target_arch in aarch64 arm i686 x86_64; do
    echo "[*] Building packages for architecture '$target_arch':"
    build_log="./binary-packages/build-${target_arch}.log"

    for pkg in $PACKAGE_NAMES; do
        echo "[+]   Processing ${pkg}:"

        for dep_pkg in $(./scripts/buildorder.py "./packages/$pkg" | xargs -r -n 1 basename); do
            echo -n "[+]     Compiling dependency ${dep_pkg}... "
            if ./build-package.sh -o ./binary-packages -a "$target_arch" "$dep_pkg" >> $build_log 2>&1; then
                echo "ok"
            else
                echo "fail"
                echo "[*] Uploading log file..."
                log_name="build-${pkg}-${target_arch}-$(date +%d.%m.%Y-%H.%M).log"
                log_url=$(curl --silent --upload-file "$build_log" "https://transfer.sh/$log_name")
                echo
                echo "    Log: $log_url"
                echo
                exit 1
            fi
        done

        echo -n "[+]     Compiling ${pkg}... "
        if ./build-package.sh -o ./binary-packages -a "$target_arch" "$pkg" > $build_log 2>&1; then
            echo "ok"
        else
            echo "fail"
            echo "[*] Uploading log file..."
            log_name="build-${pkg}-${target_arch}-$(date +%d.%m.%Y-%H.%M).log"
            log_url=$(curl --silent --upload-file "$build_log" "https://transfer.sh/$log_name")
            echo
            echo "    Log: $log_url"
            echo
            exit 1
        fi
    done
done

## Create archive with packages and logs.
echo -n "[*] Archiving packages and logs... "
archive_name="build-$(date +%d.%m.%Y-%H.%M).tar.gz"
if tar zcf "$archive_name" binary-packages > /dev/null 2>&1; then
    echo "ok"
else
    echo "fail"
    exit 1
fi

## Upload archive.
echo "[*] Uploading..."
archive_url=$(curl --silent --upload-file "$archive_name" "https://transfer.sh/$archive_name")
echo
echo "    Build result: $archive_url"
echo
echo "[*] Finished successfully."
