## Termux mods and scripts

Here you can find a various [Termux](https://termux.com)-related stuff [I](https://github.com/xeffyr) have been worked on.
Note that some things may be really outdated and/or contain issues. Use them on your own risk.

### What is available here:

#### Development stuff

A section with various Termux-related development stuff.

* [Build recipes for containers](./termux-dev/containers)

  Contain build scripts (recipes) for creating containers. For now only there available only Singulariy container recipe.

#### Mods

A section with advanced modifications of Termux.

* [termux-musl](./termux-musl)

  An experiment with building all Termux packages against [Musl libc](https://www.musl-libc.org/). Includes all necessary patches
  and scripts for building cross-compilers as well as all necessary stuff for building packages. *Discontinued.*

#### Utilities

A section with scripts and utilities that should work with typical Termux installation.

* [termux-builder](./termux-builder)

  An attempt to port [termux-packages](https://github.com/termux/termux-packages) Docker image to make it usable on device. Uses
  qemu-user with proot.

* [termux-makepkg](./termux-makepkg)

  A tiny build system for Termux to make source-based custom package distribution easier.
  Inspired by utility "makepkg" from [Arch Linux](https://www.archlinux.org/) and build script format from [termux-packages](https://github.com/termux/termux-packages)
  environment.
