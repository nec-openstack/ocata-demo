#!/bin/sh

. /etc/sysconfig/heat-params

docker run -d \
  --restart always \
  --name=registrator \
  --net=host \
  --volume=/var/run/docker.sock:/tmp/docker.sock \
  gliderlabs/registrator:latest \
    consul://localhost:8500
