# Senlin

## Create a profile(pro_worker) for docker-worker

    $ # Using worker template(./heat/work.yml)
    $ cd ocata-demo/senlin
    $ senlin profile-create -s worker_spec.yaml swarm-worker-profile

## Create a cluster

    $ senlin cluster-create -p swarm-worker-profile swarm-worker

## Create a receiver and bond it to CLUSTER_SCALE_OUT action

    $ senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_OUT scale-out-receiver

## Got the webhook url from receiver

    $ senlin receiver-show scale-out-receiver

## Configure the webhook url to altermanager.yml

### Edit alertmanager.yml

    $ ALERTMANAGER_CONF_DIR="/srv/docker/alertmanager"
    $ ALERTMANAGER_CONF=${ALERTMANAGER_CONF_DIR}/alertmanager.yml
    $ HOOK_URL=`openstack cluster receiver show scale-out-receiver \
                  -c channel -f value | \
                grep alarm_url | \
                sed -e "s/.*\(http.*V\=1\).*/\1/"`
    $ sed -i -e "s/SENLIN_SERVER_RECEIVER_URL/${HOOK_URL}/g" ${ALERTMANAGER_CONF}

### Reload alertmanager

    $ docker restart alertmanager
