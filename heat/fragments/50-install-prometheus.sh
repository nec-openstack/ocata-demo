#!/bin/sh

. /etc/sysconfig/heat-params

CONTAINER_TAR_DIRECTORY=/srv/docker/tars/
docker load < ${CONTAINER_TAR_DIRECTORY}/prometheus.tar
docker load < ${CONTAINER_TAR_DIRECTORY}/alertmanager.tar

PROMETHEUS_CONF_DIR="/srv/docker/prometheus"
PROMETHEUS_CONF=${PROMETHEUS_CONF_DIR}/prometheus.yml
PROMETHEUS_ALERT_CONF=${PROMETHEUS_CONF_DIR}/alert.rules

ALERTMANAGER_CONF_DIR="/srv/docker/alertmanager"
ALERTMANAGER_CONF=${ALERTMANAGER_CONF_DIR}/alertmanager.yml

mkdir -p ${PROMETHEUS_CONF_DIR}
mkdir -p ${ALERTMANAGER_CONF_DIR}

cat > ${PROMETHEUS_CONF} <<'EOF'
$PROMETHEUS_CONFIG
EOF

cat > ${PROMETHEUS_ALERT_CONF} <<'EOF'
$PROMETHEUS_ALERT_CONFIG
EOF

cat > ${ALERTMANAGER_CONF} <<'EOF'
$ALERTMANAGER_CONFIG
EOF

docker run \
    --volume=${PROMETHEUS_CONF}:/etc/prometheus/prometheus.yml \
    --volume=${PROMETHEUS_ALERT_CONF}:/etc/prometheus/alert.rules \
    --detach=true \
    --name=prometheus \
    --net=host \
    --restart always \
    prom/prometheus:latest \
    -alertmanager.url=http://localhost:9093 \
    -config.file=/etc/prometheus/prometheus.yml \
    -storage.local.path=/prometheus \
    -web.console.libraries=/etc/prometheus/console_libraries \
    -web.console.templates=/etc/prometheus/consoles \
    -query.staleness-delta=10s

docker run \
    --restart always \
    --volume=${ALERTMANAGER_CONF}:/etc/alertmanager/config.yml \
    --net=host \
    --detach=true \
    --name alertmanager \
    prom/alertmanager:latest
