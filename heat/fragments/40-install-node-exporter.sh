#!/bin/sh

. /etc/sysconfig/heat-params

CONTAINER_TAR_DIRECTORY=/srv/docker/tars/
docker load < ${CONTAINER_TAR_DIRECTORY}/node-exporter.tar

docker run -d -p 9100:9100 \
    --restart always \
    -e "SERVICE_NAME=node" \
    -v "/proc:/host/proc" \
    -v "/sys:/host/sys" \
    -v "/:/rootfs" \
    --net="host" \
    --name=node-exporter \
    prom/node-exporter \
    -collector.procfs /host/proc \
    -collector.sysfs /host/sys \
    -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"
