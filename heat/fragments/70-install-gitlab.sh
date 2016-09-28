#!/bin/sh

. /etc/sysconfig/heat-params

CONTAINER_TAR_DIRECTORY=/srv/docker/tars/
docker load < ${CONTAINER_TAR_DIRECTORY}/ubuntu-ruby.tar
docker load < ${CONTAINER_TAR_DIRECTORY}/redis.tar
docker load < ${CONTAINER_TAR_DIRECTORY}/postgresql.tar
docker load < ${CONTAINER_TAR_DIRECTORY}/gitlab.tar

GITLAB_CONF_DIR="/srv/docker/gitlab"
GITLAB_DOCKER_COMPOSE=${GITLAB_CONF_DIR}/docker-compose.yml

mkdir -p ${GITLAB_CONF_DIR}

cat > ${GITLAB_DOCKER_COMPOSE} <<EOF
$GITLAB_DOCKER_COMPOSE
EOF
sed -i "s/__GITLAB_HOST__/${MANAGER_IP_PUBLIC}/g" ${GITLAB_DOCKER_COMPOSE}

cd ${GITLAB_CONF_DIR}
docker-compose up -d
