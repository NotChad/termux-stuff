##
## Build with:
##   docker build -t xeffyr/termux-musl-env-builder .
##
## Push to docker hub with:
##   docker push xeffyr/termux-musl-env-builder
##

FROM alpine:3.8

# Make sure that everything is up-to-date.
RUN apk upgrade

# Install basic build tools (binutils, gcc, make, etc...).
RUN apk add alpine-sdk

# Install additional essential packages.
RUN apk add autoconf automake bash bison coreutils cmake diffutils dpkg findutils \
    flex gawk gettext gettext-dev gmp-dev go grep isl-dev libtool mpc1-dev mpfr-dev \
    ncurses ncurses-dev ninja python3 sed texinfo xz zip zlib-dev

# Install developer tools.
RUN apk add nano the_silver_searcher patchutils

# Create user and add it to sudoers.
RUN apk add shadow sudo && \
    sed -i "s/CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/g" /etc/default/useradd && \
    useradd -U -m -s /bin/ash builder && \
    echo "builder ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/builder

# Create necessary directories.
RUN mkdir /data && chown builder:builder /data && \
    mkdir -p /opt/termux && chown builder:builder /opt/termux

# Compile toolchain.
COPY . /home/builder/termux-musl
RUN chown builder:builder -Rh /home/builder/termux-musl && \
    su - builder -c "env TERMUX_ARCH=aarch64 /home/builder/termux-musl/cross-toolchain/build-toolchain.sh" && \
    su - builder -c "env TERMUX_ARCH=arm /home/builder/termux-musl/cross-toolchain/build-toolchain.sh" && \
    su - builder -c "env TERMUX_ARCH=i686 /home/builder/termux-musl/cross-toolchain/build-toolchain.sh" && \
    su - builder -c "env TERMUX_ARCH=x86_64 /home/builder/termux-musl/cross-toolchain/build-toolchain.sh" && \
    rm -rf /home/builder/termux-musl /home/builder/.toolchain_build

# Prevent using for ldconfig by libtool.
COPY ./scripts/fake-ldconfig.sh /usr/local/bin/ldconfig
RUN chmod 755 /usr/local/bin/ldconfig

# Set work directory to our repository.
WORKDIR /home/builder/termux-musl
