## Recipes for containers

Recipes for Termux development containers.

**Not for on-device use !!!**

### Singularity

Singularity is a free, cross-platform and open-source computer program that performs operating-system-level virtualization also known as containerization.

Home page: https://www.sylabs.io/singularity/

Github: https://github.com/sylabs/singularity

#### [Termux package builder](./Singularity.package-builder)

A package build environment similar to Docker image provided by [termux-packages](https://github.com/termux/termux-packages). Can be used in rootless environments.

##### How to

1. Create a sandbox since container should be in read-write mode:
   ```
   singularity build --sandbox ./builder shub://xeffyr/termux-stuff:package-builder
   ```

2. Run container in read-write mode:
   ```
   singularity run -w ./builder
   ```
   If your system supports *User Namespaces*, you can use them to run container in *rootless* mode:
   ```
   singularity run -wu ./builder
   ```

3. If no errors appeared, you should be in your home directory but rootfs will be switched. Now you can clone a Termux packages repository:
   ```
   git clone https://github.com/termux/termux-packages
   ```

4. Verify that everything is working. Compile a simple package:
   ```
   ./build-package.sh libandroid-support
   ```
   
   Note that container is forced to use 4 make jobs by default. You can always change this value by setting appropriate environment variable. Example for allowing only 2 make jobs:
   ```
   export TERMUX_MAKE_PROCESSES=2
   ```
   
   Unlike original [termux-packages](https://github.com/termux/termux-packages) build environment, Android SDK and NDK are stored in /opt folder inside container. Build directories are: /data - for installing compiled stuff and /var/lib/termux-builder for storing sources and build directories.
