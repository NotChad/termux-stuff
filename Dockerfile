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
RUN apk add bash bison flex gawk gmp-dev gmp-dev isl-dev mpc1-dev \
    mpc1-dev mpfr-dev mpfr-dev texinfo xz zip zlib-dev zlib-dev

# Create user and add it to sudoers.
RUN apk add shadow sudo && \
    sed -i "s/CREATE_MAIL_SPOOL=yes/CREATE_MAIL_SPOOL=no/g" /etc/default/useradd && \
    useradd -U -m -s /bin/ash builder && \
    echo "builder ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/builder

# Create necessary directories.
RUN mkdir /data && chown builder:builder /data && \
    mkdir -p /opt/termux && chown builder:builder /opt/termux

# Set work directory to our repository.
WORKDIR /home/builder/termux-musl
