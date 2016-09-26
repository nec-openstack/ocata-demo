#!/bin/sh

. /etc/sysconfig/heat-params

GITLAB_CONF_DIR="/srv/docker/gitlab"
GITLAB_DOCKER_COMPOSE=${GITLAB_CONF_DIR}/docker-compose.yml

mkdir -p ${GITLAB_CONF_DIR}

cats > ${GITLAB_DOCKER_COMPOSE} <<EOF
$GITLAB_DOCKER_COMPOSE
EOF

cd ${GITLAB_CONF_DIR}
docker-compose up -d
