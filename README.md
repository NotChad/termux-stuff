# Termux:Musl

An alternate build environment for Termux for creating packages linked with [Musl libc](https://www.musl-libc.org/).

## How to

### Getting started

1. Clone the repository:
   ```
   git clone https://github.com/xeffyr/termux-musl.git
   ```

2. Setup and start environment (requires docker):
   ```
   ./start-builder.sh
   ```
   Sometimes, a new docker image may be released. In this case you may need to install the updated image with this command:
   ```
   ./scripts/update-docker.sh
   ```

### Building cross-compiler

Usually, there no need to rebuild cross-compiler provided with docker image. But if you want to do that, just execute this command from the root of repository:
```
./scripts/cross-toolchain/build-toolchain.sh
```

By default, cross compiler is built for AArch64. If you need a different architecture, export environment variable `TERMUX_ARCH`. It's value should be a one of: aarch64, arm, i686, x86_64. Example for building ARM cross-compiler:
```
TERMUX_ARCH=arm ./scripts/cross-toolchain/build-toolchain.sh
```

When build finishes, you can find toolchain in /opt/termux directory.

### Building packages

Packages can be built with this command:
```
./build-package.sh {package}
```
Where '{package}' should be replaced with actual name of the package (e.g. bash). To see what packages are available, check directory [./packages](./packages).

## Known issues

It is not possible to know all issues at the one time, but major ones are:

* Musl libc: shared memory functions may throw error '`Bad system call`'. This is because Android allows only ashmem-based shared memory.

## Useful links

- [Termux application](https://github.com/termux/termux-app) - application sources on Github.
- [Termux packages](https://github.com/termux/termux-packages) - package build recipes on Github.
- [Cross Linux From Scratch (embedded)](http://trac.clfs.org/wiki/download#EmbeddedDevelopment) - learn steps for creating cross-compiling environment.
- [Alpine Linux aports](https://git.alpinelinux.org/cgit/aports) - patches and package recipes.
