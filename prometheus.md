# Install prometheus

    $ sudo mkdir /srv/docker/prometheus
    $ sudo cp prometheus/prometheus.yml /srv/docker/prometheus/prometheus.yml
    $ docker run \
        --volume=/srv/docker/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
        --detach=true \
        --name=prometheus \
        --net=host \
        --restart always \
        prom/prometheus:latest

## Promdash

    $ docker pull prom/promdash
    $ docker run -v /tmp/prom:/tmp/prom \
        -e DATABASE_URL=sqlite3:/tmp/prom/file.sqlite3 \
        prom/promdash ./bin/rake db:migrate
    $ docker run -d -p 3000:3000 -v /tmp/prom:/tmp/prom \
        -e DATABASE_URL=sqlite3:/tmp/prom/file.sqlite3 \
        prom/promdash
