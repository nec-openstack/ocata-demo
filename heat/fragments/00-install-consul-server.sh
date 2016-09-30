#!/bin/sh

. /etc/sysconfig/heat-params

CONTAINER_TAR_DIRECTORY=/srv/docker/tars/
docker load < ${CONTAINER_TAR_DIRECTORY}/consul.tar

docker run -d --net=host --name consul-server \
    -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
    consul agent -server -bind=0.0.0.0 -advertise=${MANAGER_IP} \
                -bootstrap-expect=1 -ui

docker run -d --net=host \
    --name deregister \
    -p 4567:4567 \
    yuanying/deregister
