#!/bin/sh

. /etc/sysconfig/heat-params

PROMETHEUS_CONF_DIR="/srv/docker/prometheus"
PROMETHEUS_CONF=${PROMETHEUS_CONF_DIR}/prometheus.yml
PROMETHEUS_ALERT_CONF=${PROMETHEUS_CONF_DIR}/alert.rules

mkdir -p ${PROMETHEUS_CONF_DIR}

cat > ${PROMETHEUS_CONF} <<EOF
$PROMETHEUS_CONFIG
EOF

cat > ${PROMETHEUS_ALERT_CONF} <<EOF
$PROMETHEUS_ALERT_CONFIG
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
    -web.console.templates=/etc/prometheus/consoles

docker run \
    --restart always \
    --net=host \
    --detach=true \
    --name alertmanager \
    prom/alertmanager:latest
