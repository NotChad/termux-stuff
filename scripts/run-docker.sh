#!/bin/sh
set -e -u

REPOROOT="$(dirname $(realpath ${0}))/../"
CONTAINER_HOME="/home/builder"
CONTAINER_USER="builder"

IMAGE_NAME="xeffyr/termux-musl-env-builder"
: ${CONTAINER_NAME:=termux-musl-builder}

echo "Running container '${CONTAINER_NAME}' from image '${IMAGE_NAME}'..."

docker start "${CONTAINER_NAME}" > /dev/null 2> /dev/null || {
    echo "Creating new container..."

    docker run \
           --name "${CONTAINER_NAME}" \
           --detach \
           --tty \
           --env "HOME=${CONTAINER_HOME}" \
           --volume "${REPOROOT}:${CONTAINER_HOME}/termux-musl" \
           "${IMAGE_NAME}"

    if [ $(id -u) -ne 1000 -a $(id -u) -ne 0 ]; then
        echo "Changed builder uid/gid... (this may take a while)"
        docker exec --tty "${CONTAINER_NAME}" chown -R $(id -u) "${CONTAINER_HOME}"
        docker exec --tty "${CONTAINER_NAME}" chown -R $(id -u) /data
        docker exec --tty "${CONTAINER_NAME}" usermod -u $(id -u) builder
        docker exec --tty "${CONTAINER_NAME}" groupmod -g $(id -g) builder
    fi
}

if [ "${#}" -eq  "0" ]; then
    docker exec --interactive --tty --user "${CONTAINER_USER}" "${CONTAINER_NAME}" ash
else
    docker exec --interactive --tty --user "${CONTAINER_USER}" "${CONTAINER_NAME}" "${@}"
fi
