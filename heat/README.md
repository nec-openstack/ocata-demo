# How to use

## Add your keypair

    $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub default

## Build Swarm manager

    $ heat stack-create -f manager.yml -e manager-params.yml swarm-manager
