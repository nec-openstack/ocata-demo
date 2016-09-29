# ocata-demo
Demo for ocata

## Common

### Clone devstack and ocata-demo repository

    $ git clone https://git.openstack.org/openstack-dev/devstack ~/devstack
    $ git clone https://github.com/nec-openstack/ocata-demo ~/ocata-demo

### Install devstack

    $ cp ~/ocata-demo/devstack/local.conf ~/devstack/
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
    $ sed -i -e "s/__SWARM_SG__/${SWARM_SG}/g" ./worker_spec.yaml
    $ sed -i -e "s/__SWARM_MANAGER_IP__/${SWARM_MANAGER_IP}/g" ./worker_spec.yaml
    $ sed -i -e "s/__SWARM_TOKEN__/${SWARM_TOKEN}/g" ./worker_spec.yaml
    $ senlin profile-create -s worker_spec.yaml swarm-worker-profile

### Create a cluster

    $ senlin cluster-create -p swarm-worker-profile swarm-worker

### Create a receiver and bond it to CLUSTER_SCALE_OUT action

    $ senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_OUT scale-out-receiver

### Edit alertmanager.yml

    $ ALERTMANAGER_CONF_DIR="/srv/docker/alertmanager"
    $ ALERTMANAGER_CONF=${ALERTMANAGER_CONF_DIR}/alertmanager.yml
    $ SWARM_MANAGER_FIP=`heat output-show -F raw swarm-manager floating_ip`
    $ HOOK_URL=`openstack cluster receiver show scale-out-receiver \
                  -c channel -f value | \
                grep alarm_url | \
                sed -e "s/.*\(http.*V\=1\).*/\1/"`
    $ echo "sudo sed -i -e \"s|SENLIN_SERVER_RECEIVER_URL|${HOOK_URL}|g\" \
        ${ALERTMANAGER_CONF}" | ssh ubuntu@${SWARM_MANAGER_FIP} bash

### Reload alertmanager on manager node

    $ ssh ubuntu@${SWARM_MANAGER_FIP} sudo docker restart alertmanager

### Build first node by hand

    $ senlin cluster-scale-out -c 1 swarm-worker

## Setup gitlab

## Test Demo

    $ docker service create \
        --constraint 'node.role != manager' \
        yuanying/ubuntu-ruby:2.3.1 \
        sleep 100
