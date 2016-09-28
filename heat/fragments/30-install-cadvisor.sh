#!/bin/sh

. /etc/sysconfig/heat-params

CONTAINER_TAR_DIRECTORY=/srv/docker/tars/
docker load < ${CONTAINER_TAR_DIRECTORY}/cadvisor.tar

docker run \
    --restart always \
    --volume=/:/rootfs:ro \
    --volume=/var/run:/var/run:rw \
    --volume=/sys:/sys:ro \
    --volume=/var/lib/docker/:/var/lib/docker:ro \
    --publish=8080:8080 \
    --detach=true \
    --name=cadvisor \
    google/cadvisor:latest
