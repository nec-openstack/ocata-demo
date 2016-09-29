# Server

## Install consul

    $ docker run -d --net=host --name consul-server \
        -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
        consul agent -server -bind=0.0.0.0 -advertise=192.168.204.21 \
                    -bootstrap-expect=1 -ui

# Agent

    $ docker run -d --net=host --name consul-agent \
        --restart always \
        -e 'CONSUL_BIND_INTERFACE=eth0' \
        -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' \
        consul agent -join 192.168.204.21
    $ docker run -d \
      --restart always \
      --name=registrator \
      --net=host \
      --volume=/var/run/docker.sock:/tmp/docker.sock \
      gliderlabs/registrator:latest \
        consul://localhost:8500

## cAdvisor

    $ docker run \
        --restart always \
        --volume=/:/rootfs:ro \
        --volume=/var/run:/var/run:rw \
        --volume=/sys:/sys:ro \
        --volume=/var/lib/docker/:/var/lib/docker:ro \
        --publish=8080:8080 \
        --detach=true \
        --name=cadvisor \
        google/cadvisor:latest

## node-exporter

    $ docker run -d -p 9100:9100 \
        --restart always \
        -e "SERVICE_NAME=node" \
        -v "/proc:/host/proc" \
        -v "/sys:/host/sys" \
        -v "/:/rootfs" \
        --name=node-exporter \
        prom/node-exporter \
        -collector.procfs /host/proc \
        -collector.sysfs /host/sys \
        -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"

# Swarm mode

## Network

    $ docker network create consul -d overlay

## Consul

    $ docker service create --name consul-server \
        -p 8301:8300 \
        --network consul \
        -e 'CONSUL_BIND_INTERFACE=eth0' \
        --constraint 'node.role == manager' \
        consul agent -server -bootstrap-expect=1 \
        -retry-join=consul-server:8301

    $ docker service create \
      -e 'CONSUL_BIND_INTERFACE=eth0' \
      -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true, "retry_join":["consul-server:8301"]}' \
      --publish "8500:8500" \
      --replicas 1 \
      --network consul \
      --name consul-agent \
      --constraint 'node.role != manager' \
      consul agent -client 0.0.0.0

## Registrator

    $ docker service create \
      --name=registrator \
      --network consul \
      --mode global \
      --mount type=bind,source=/var/run/docker.sock,target=/tmp/docker.sock \
      gliderlabs/registrator:latest \
        -internal \
        consul://consul-agent:8500

## cAdvisor

    $ docker service create \
        --mount type=bind,source=/,target=/rootfs \
        --mount type=bind,source=/var/run,target=/var/run \
        --mount type=bind,source=/sys,target=/sys \
        --mount type=bind,source=/var/lib/docker/,target=/var/lib/docker/ \
        --publish=8080:8080 \
        --name=cadvisor \
        --network consul \
        --mode global \
        google/cadvisor:latest

## node-exporter

    $ docker service create -p 9100:9100 \
        -e "SERVICE_NAME=node" \
        --mount type=bind,source=/,target=/rootfs \
        --mount type=bind,source=/proc,target=/host/proc \
        --mount type=bind,source=/sys,target=/host/sys \
        --network consul \
        --name=node-exporter \
        --mode global \
        prom/node-exporter \
        -collector.procfs /host/proc \
        -collector.sysfs /host/sys \
        -collector.filesystem.ignored-mount-points "^/(sys|proc|dev|host|etc)($|/)"

# Reference

- https://kjmkznr.github.io/post/consul-prometheus/
