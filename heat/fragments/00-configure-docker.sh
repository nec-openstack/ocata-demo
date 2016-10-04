#!/bin/sh

. /etc/sysconfig/heat-params

echo "export http_proxy=${HTTP_PROXY}" >> /etc/default/docker
echo "export https_proxy=${HTTPS_PROXY}" >> /etc/default/docker

# WARNING: Listen all interface unsafely
echo "DOCKER_OPTS='-H unix:///var/run/docker.sock -H tcp://0.0.0.0:2375'" >> /etc/default/docker

service docker restart

sleep 3

docker swarm init

sleep 3
docker node update --availability drain `hostname`

REGISTRY_CONF_DIR="/srv/docker/registry"
REGISTRY_CONF=${REGISTRY_CONF_DIR}/config.yml

mkdir -p ${REGISTRY_CONF_DIR}
cat > ${REGISTRY_CONF} <<'EOF'
$REGISTRY_CONFIG
EOF

docker run -d --restart=always \
    -p 5000:5000 --name v2-mirror \
    -v ${REGISTRY_CONF_DIR}:/var/lib/registry \
    registry:2.3 /var/lib/registry/config.yml
