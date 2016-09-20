# Server

## Install consul

    $ docker run -d --net=host --name consul-server \
        -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
        consul agent -server -bind=192.168.204.21 -bootstrap-expect=1 \
                     -ui -client=192.168.204.21

## Install consul-template

    $ sudo su -
    # CONSUL_TEMPLATE_VERSION=0.14.0
    # curl -O https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip \
        && unzip consul-template_0.14.0_linux_amd64.zip \
        && mv consul-template /usr/local/bin \
        && rm -f consul-template_0.14.0_linux_amd64.zip

# Agent

    $ docker run -d --net=host --name consul-agent \
        -e 'CONSUL_BIND_INTERFACE=eth0' \
        -e 'CONSUL_LOCAL_CONFIG={"leave_on_terminate": true}' \
        consul agent -join 192.168.204.21
    $ docker run -d \
      --name=registrator \
      --net=host \
      --volume=/var/run/docker.sock:/tmp/docker.sock \
      gliderlabs/registrator:latest \
        consul://localhost:8500

## cAdvisor

    $ docker run \
        --volume=/:/rootfs:ro \
        --volume=/var/run:/var/run:rw \
        --volume=/sys:/sys:ro \
        --volume=/var/lib/docker/:/var/lib/docker:ro \
        --publish=8080:8080 \
        --detach=true \
        --name=cadvisor \
        google/cadvisor:latest

## Reference

- https://kjmkznr.github.io/post/consul-prometheus/
