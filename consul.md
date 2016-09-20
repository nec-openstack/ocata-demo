# Server

## Install consul

    $ cd ocata-demo/consul
    $ docker-compose up -d

## Install consul-template

    $ sudo su -
    # CONSUL_TEMPLATE_VERSION=0.14.0
    # curl -O https://releases.hashicorp.com/consul-template/0.14.0/consul-template_0.14.0_linux_amd64.zip \
        && unzip consul-template_0.14.0_linux_amd64.zip \
        && mv consul-template /usr/local/bin \
        && rm -f consul-template_0.14.0_linux_amd64.zip

# Agent

    $ docker service create --name consul-agent \
        --mode global \
        --network host \
        consul agent -join 192.168.204.21

## Reference

- https://kjmkznr.github.io/post/consul-prometheus/
