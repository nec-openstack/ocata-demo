# How to use

## Add your keypair

    $ nova keypair-add --pub-key ~/.ssh/id_rsa.pub default

## Build inception and senlin server

    $ heat stack-create -f bootstrap.yaml -e bootstrap-params.yaml bootstrap

## Build Swarm manager

    $ heat stack-create -f manager.yaml -e manager-params.yaml swarm-manager
