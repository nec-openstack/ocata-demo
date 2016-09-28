# Senlin

## Create a profile(pro_worker) for docker-worker

    $ # Using worker template(./heat/work.yml)
    $ cd ocata-demo/senlin
    $ SWARM_SG=`heat output-show -F raw swarm-manager security_group`
    $ SWARM_MANAGER_IP=`heat output-show -F raw swarm-manager fixed_ip`
    $ SWARM_TOKEN=`heat output-show -F raw swarm-manager swarm_worker_token`
    $ sed -i -e "s/__SWARM_SG__/${SWARM_SG}/g" ./worker_spec.yaml
    $ sed -i -e "s/__SWARM_MANAGER_IP__/${SWARM_MANAGER_IP}/g" ./worker_spec.yaml
    $ sed -i -e "s/__SWARM_TOKEN__/${SWARM_TOKEN}/g" ./worker_spec.yaml
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
