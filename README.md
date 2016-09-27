# ocata-demo
Demo for ocata

## Common

### Get OS image and register to Glance

    $ curl -O https://fedorapeople.org/groups/magnum/ubuntu-trusty-docker.qcow2
    $ glance image-create --name ubuntu-docker \
                          --os-distro ubuntu \
                          --visibility public \
                          --disk-format=qcow2 \
                          --container-format=bare \
                          --file=ubuntu-trusty-docker.qcow2

## Setup inception vm

## Setup senlin server

## Setup swarm manager

## Setup swarm worker

## Setup gitlab
