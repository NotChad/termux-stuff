# Termux:Musl

An alternate build environment for Termux for creating packages linked with [Musl libc](https://www.musl-libc.org/).

> THIS PROJECT IS DISCONTINUED !<br><br>
It was just an experiment. Despite the fact that experiment was successful, [I](https://github.com/xeffyr) cannot continue to develop it. I have no desire|opportunity|time to deal with custom cross compiler, fixing build environment and various caveats and bugs hidden there. I'm not saying that porting and maintaining the package tree is a headache for one persion.<br>
Package repository related to this project will be shutted down, it's dump can be found on the Internet Archive: https://archive.org/details/termux-musl-repository-25.01.2019.tar. Related docker image will be removed to, so if you decide to continue this project some things should be built manually.

## How to

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
