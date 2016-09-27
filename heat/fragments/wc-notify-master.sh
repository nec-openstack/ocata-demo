#!/bin/sh

. /etc/sysconfig/heat-params

SWARM_WORKER_TOKEN=`docker swarm join-token -q worker`
SWARM_MANAGER_TOKEN=`docker swarm join-token -q manager`

sh -c "$WAIT_CURL --data-binary '{\"status\": \"SUCCESS\",\"id\": \"worker\",\"data\": \"${SWARM_WORKER_TOKEN}\"}'"
sh -c "$WAIT_CURL --data-binary '{\"status\": \"SUCCESS\",\"id\": \"manager\",\"data\": \"${SWARM_MANAGER_TOKEN}\"}'"
