#!/bin/sh

. /etc/sysconfig/heat-params

CONTAINER_TAR_DIRECTORY=/srv/docker/tars/
docker load < ${CONTAINER_TAR_DIRECTORY}/registrator.tar

docker run -d \
  --restart always \
  --name=registrator \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    consul://localhost:8500
