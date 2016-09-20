# Install prometheus

    $ sudo mkdir /srv/docker/prometheus
    $ sudo cp prometheus/prometheus.yml /srv/docker/prometheus/prometheus.yml
    $ cd prometheus
    $ docker-compose up -d

## Install container exporter

    $ docker run -p 8080:8080 -v /cgroup:/cgroup \
        -v /var/run/docker.sock:/var/run/docker.sock prom/container-exporter
