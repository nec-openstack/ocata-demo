#!/bin/sh

. /etc/sysconfig/heat-params

GITLAB_CONF_DIR="/srv/docker/gitlab"
GITLAB_DOCKER_COMPOSE=${GITLAB_CONF_DIR}/docker-compose.yml

mkdir -p ${GITLAB_CONF_DIR}

cat > ${GITLAB_DOCKER_COMPOSE} <<EOF
$GITLAB_DOCKER_COMPOSE
EOF
sed -i "s/__GITLAB_HOST__/${MANAGER_IP_PUBLIC}/g" ${GITLAB_DOCKER_COMPOSE}

cd ${GITLAB_CONF_DIR}
docker-compose up -d
