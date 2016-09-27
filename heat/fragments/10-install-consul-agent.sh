#!/bin/sh

. /etc/sysconfig/heat-params

docker run -d --net=host --name consul-agent \
    --restart always \
    -e 'CONSUL_BIND_INTERFACE=eth0' \
    -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' \
    consul agent -join ${MANAGER_IP}
