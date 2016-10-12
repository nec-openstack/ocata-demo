#!/bin/bash

set -x
set -eu
set -o pipefail

nova flavor-create m.swarm sm 4096 40 1
nova flavor-create w.swarm wm 1024 20 1

cd ~/ocata-demo/heat

heat stack-create --poll -f manager.yaml -e manager-params.yaml swarm-manager

cd ~/ocata-demo/senlin
SWARM_SG=`heat output-show -F raw swarm-manager security_group`
SWARM_MANAGER_IP=`heat output-show -F raw swarm-manager fixed_ip`
SWARM_TOKEN=`heat output-show -F raw swarm-manager swarm_worker_token`
sed -e "s/__SWARM_SG__/${SWARM_SG}/g" ./worker_spec.yaml > ./worker_spec.tmp.yaml
sed -i -e "s/__SWARM_MANAGER_IP__/${SWARM_MANAGER_IP}/g" ./worker_spec.tmp.yaml
sed -i -e "s/__SWARM_TOKEN__/${SWARM_TOKEN}/g" ./worker_spec.tmp.yaml
senlin profile-create -s worker_spec.tmp.yaml swarm-worker-profile

senlin cluster-create -p swarm-worker-profile swarm-worker

cat > deletion_policy.yaml <<EOF
# Sample deletion policy that can be attached to a cluster.
type: senlin.policy.deletion
version: 1.0
description: A policy for choosing victim node(s) from a cluster for deletion.
properties:
  # The valid values include:
  # OLDEST_FIRST, OLDEST_PROFILE_FIRST, YOUNGEST_FIRST, RANDOM
  criteria: YOUNGEST_FIRST

  # Whether deleted node should be destroyed
  destroy_after_deletion: True

  # Length in number of seconds before the actual deletion happens
  # This param buys an instance some time before deletion
  grace_period: 60

  # Whether the deletion will reduce the desired capacity of
  # the cluster as well
  reduce_desired_capacity: False
EOF
senlin policy-create -s deletion_policy.yaml worker-deletion-policy
senlin cluster-policy-attach -p worker-deletion-policy swarm-worker

senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_OUT scale-out-receiver
senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_IN scale-in-receiver

ALERTMANAGER_CONF_DIR="/srv/docker/alertmanager"
ALERTMANAGER_CONF=${ALERTMANAGER_CONF_DIR}/alertmanager.yml
SWARM_MANAGER_FIP=`heat output-show -F raw swarm-manager floating_ip`
SCALE_OUT_HOOK_URL=`openstack cluster receiver show scale-out-receiver \
              -c channel -f value | \
            grep alarm_url | \
            sed -e "s/.*\(http.*V\=1\).*/\1/"`
echo "sudo sed -i -e \"s|SENLIN_OUT_RECEIVER_URL|${SCALE_OUT_HOOK_URL}|g\" \
    ${ALERTMANAGER_CONF}" | ssh ubuntu@${SWARM_MANAGER_FIP} bash
SCALE_IN_HOOK_URL=`openstack cluster receiver show scale-in-receiver \
              -c channel -f value | \
            grep alarm_url | \
            sed -e "s/.*\(http.*V\=1\).*/\1/"`
echo "sudo sed -i -e \"s|SENLIN_IN_RECEIVER_URL|${SCALE_IN_HOOK_URL}|g\" \
    ${ALERTMANAGER_CONF}" | ssh ubuntu@${SWARM_MANAGER_FIP} bash

ssh ubuntu@${SWARM_MANAGER_FIP} sudo docker restart alertmanager
