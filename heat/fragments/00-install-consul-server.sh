#!/bin/sh

. /etc/sysconfig/heat-params

docker run -d --net=host --name consul-server \
    --restart always \
    -e 'CONSUL_LOCAL_CONFIG={"skip_leave_on_interrupt": true}' \
    consul agent -server -bind=0.0.0.0 -advertise=${MANAGER_IP} \
                -bootstrap-expect=1 -ui

DEREGISTER_CONF_DIR="/srv/docker/deregister"
DEREGISTER_CONF=${DEREGISTER_CONF_DIR}/config.yml

mkdir -p ${DEREGISTER_CONF_DIR}

cat > ${DEREGISTER_CONF} <<'EOF'
$DEREGISTER_CONFIG
EOF

docker run -d --net=host \
    --restart always \
    --name deregister \
    --volume=${DEREGISTER_CONF}:/app/config.new.yaml \
    -e CONFIG_FILE="/app/config.new.yaml" \
    -p 4567:4567 \
    yuanying/deregister
