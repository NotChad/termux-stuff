# Termux:Musl

An experimental build environment for Termux for creating packages linked with [Musl libc](https://www.musl-libc.org/).

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

### Building cross-compiler

Usually, there no need to rebuild cross-compiler provided with docker image. But if you want to do that, just execute this command from the root of repository:
```
./cross-toolchain/build-toolchain.sh
```

Note that as target architecture only AArch64 is supported.

### Building packages

Currently, there no any packages defined.
