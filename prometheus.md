# Install prometheus

## Prometheus

    $ sudo mkdir /srv/docker/prometheus
    $ sudo cp prometheus/prometheus.yml /srv/docker/prometheus/prometheus.yml
    $ sudo cp prometheus/alert.rules /srv/docker/prometheus/alert.rules
    $ docker run \
        --volume=/srv/docker/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
        --volume=/srv/docker/prometheus/alert.rules:/etc/prometheus/alert.rules \
        --detach=true \
        --name=prometheus \
        --net=host \
        --restart always \
        prom/prometheus:latest \
        -alertmanager.url=http://localhost:9093 \
        -config.file=/etc/prometheus/prometheus.yml \
        -storage.local.path=/prometheus \
        -web.console.libraries=/etc/prometheus/console_libraries \
        -web.console.templates=/etc/prometheus/consoles

## Alertmanager

    $ docker run \
        --restart always \
        --net=host \
        --detach=true \
        --name alertmanager \
        prom/alertmanager:latest

# Swarm mode

    $ sudo mkdir /srv/docker/prometheus
    $ sudo cp prometheus/prometheus.yml /srv/docker/prometheus/prometheus.yml
    $ sudo cp prometheus/alert.rules /srv/docker/prometheus/alert.rules
    $ docker service create \
        -p 9090:9090 \
        --mount type=bind,source=/srv/docker/prometheus/prometheus.yml,target=/etc/prometheus/prometheus.yml \
        --mount type=bind,source=/srv/docker/prometheus/alert.rules,target=/etc/prometheus/alert.rules \
        --name=prometheus \
        --network consul \
        --constraint 'node.role == manager' \
        prom/prometheus:latest \
        -config.file=/etc/prometheus/prometheus.yml \
        -storage.local.path=/prometheus \
        -web.console.libraries=/etc/prometheus/console_libraries \
        -web.console.templates=/etc/prometheus/consoles
