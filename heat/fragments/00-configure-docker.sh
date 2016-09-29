#!/bin/sh

. /etc/sysconfig/heat-params

echo "export http_proxy=${HTTP_PROXY}" >> /etc/default/docker
echo "export https_proxy=${HTTPS_PROXY}" >> /etc/default/docker
echo "http_proxy=$http_proxy" >> /etc/default/docker
echo "https_proxy=$https_proxy" >> /etc/default/docker

# WARNING: Listen all interface unsafely
echo "DOCKER_OPTS='-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375'" >> /etc/default/docker

service docker restart

sleep 3

docker swarm init
docker node update --availability drain `hostname`
