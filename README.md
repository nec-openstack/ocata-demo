# ocata-demo
Demo for ocata

## Common

### Clone devstack and ocata-demo repository

    $ git clone https://git.openstack.org/openstack-dev/devstack ~/devstack
    $ git clone https://github.com/nec-openstack/ocata-demo ~/ocata-demo

### Install devstack

    $ cp ~/ocata-demo/devstack/controller/local.* ~/devstack/
    $ cd ~/devstack
    $ ./stack.sh

### Register your ssh keypair

    $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub default

### Get OS image and register to Glance

    $ curl -O https://fedorapeople.org/groups/magnum/ubuntu-trusty-docker.qcow2
    $ glance image-create --name ubuntu-docker \
                          --os-distro ubuntu \
                          --visibility public \
                          --disk-format=qcow2 \
                          --container-format=bare \
                          --file=ubuntu-trusty-docker.qcow2

## Setup swarm manager

    $ cd ~/ocata-demo/heat
    $ nova flavor-create m.swarm sm 4096 40 1
    $ heat stack-create -f manager.yaml -e manager-params.yaml swarm-manager

## Setup swarm worker

### Create a profile for docker-worker

    $ cd ~/ocata-demo/senlin
    $ nova flavor-create w.swarm wm 1024 20 1
    $ SWARM_SG=`heat output-show -F raw swarm-manager security_group`
    $ SWARM_MANAGER_IP=`heat output-show -F raw swarm-manager fixed_ip`
    $ SWARM_TOKEN=`heat output-show -F raw swarm-manager swarm_worker_token`
    $ sed -e "s/__SWARM_SG__/${SWARM_SG}/g" ./worker_spec.yaml > ./worker_spec.tmp.yaml
    $ sed -i -e "s/__SWARM_MANAGER_IP__/${SWARM_MANAGER_IP}/g" ./worker_spec.tmp.yaml
    $ sed -i -e "s/__SWARM_TOKEN__/${SWARM_TOKEN}/g" ./worker_spec.tmp.yaml
    $ senlin profile-create -s worker_spec.tmp.yaml swarm-worker-profile

### Create a cluster

    $ senlin cluster-create -p swarm-worker-profile swarm-worker

### Create a receiver and bond it to CLUSTER_SCALE_OUT action

    $ senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_OUT scale-out-receiver
    $ senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_IN scale-in-receiver

### Edit alertmanager.yml

    $ ALERTMANAGER_CONF_DIR="/srv/docker/alertmanager"
    $ ALERTMANAGER_CONF=${ALERTMANAGER_CONF_DIR}/alertmanager.yml
    $ SWARM_MANAGER_FIP=`heat output-show -F raw swarm-manager floating_ip`
    $ SCALE_OUT_HOOK_URL=`openstack cluster receiver show scale-out-receiver \
                  -c channel -f value | \
                grep alarm_url | \
                sed -e "s/.*\(http.*V\=1\).*/\1/"`
    $ echo "sudo sed -i -e \"s|SENLIN_OUT_RECEIVER_URL|${SCALE_OUT_HOOK_URL}|g\" \
        ${ALERTMANAGER_CONF}" | ssh ubuntu@${SWARM_MANAGER_FIP} bash
    $ SCALE_IN_HOOK_URL=`openstack cluster receiver show scale-in-receiver \
                  -c channel -f value | \
                grep alarm_url | \
                sed -e "s/.*\(http.*V\=1\).*/\1/"`
    $ echo "sudo sed -i -e \"s|SENLIN_IN_RECEIVER_URL|${SCALE_IN_HOOK_URL}|g\" \
        ${ALERTMANAGER_CONF}" | ssh ubuntu@${SWARM_MANAGER_FIP} bash

### Reload alertmanager on manager node

    $ ssh ubuntu@${SWARM_MANAGER_FIP} sudo docker restart alertmanager

### Build first node by hand

    $ senlin cluster-scale-out -c 1 swarm-worker

## Setup gitlab

### Run gitlab runner

    $ export GITLAB_URL="__RPLACE_GITLAB_URL__"
    $ export GITLAB_TOKEN="__RPLACE_GITLAB_RUNNER_TOKEN__"
    $ sudo docker service create --name gitlab-runner \
      --mode global \
      --mount type=bind,target=/var/run/docker.sock,source=/var/run/docker.sock \
      --mount type=bind,target=/etc/hostname,source=/etc/hostname \
      --env="CI_SERVER_URL=${GITLAB_URL}/ci" \
      --env="REGISTRATION_TOKEN=${GITLAB_TOKEN}" \
      --env='RUNNER_EXECUTOR=docker' \
      --env='DOCKER_IMAGE=ruby:2.2' \
      --env='DOCKER_NETWORK_MODE=host' \
      --env="DOCKER_VOLUMES=/ci" \
      --env="DOCKER_PRIVILEGED=true" \
      --network ingress \
      --constraint 'node.role != manager' \
      yuanying/gitlab-runner

### Config deregister

    $ export GITLAB_TOKEN="__REPLACE_GITLAB_PRIVATE_TOKEN__"
    $ DEREGISTER_CONF_DIR="/srv/docker/deregister"
    $ DEREGISTER_CONF=${DEREGISTER_CONF_DIR}/config.yml
    $ sudo sed -i -e "s|__GITLAB_TOKEN__|${GITLAB_TOKEN}|g" \
        ${DEREGISTER_CONF}

## Test Demo

    $ docker service create \
        --name demo \
        --constraint 'node.role != manager' \
        yuanying/ubuntu-ruby:2.3.1 \
        sleep 100
    $ docker service create --name web nginx
