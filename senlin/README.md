# Senlin

## Create a profile(pro_worker) for docker-worker

    $ # Using worker template(./heat/work.yml)
    $ senlin profile-create -s ./senlin/worker_spec.yaml swarm-worker-profile

## Create a cluster

    $ senlin cluster-create -p swarm-worker-profile swarm-worker

## Create a receiver and bond it to CLUSTER_SCALE_OUT action

    $ senlin receiver-create -c swarm-worker -a CLUSTER_SCALE_OUT scale-out-receiver

## Got the webhook url from receiver

    $ senlin receiver-show scale-out-reveiver

## Configure the webhook url to altermanager.conf

### Get webhook url

    $ HOOK_URL=`openstack cluster receiver show scale-out-receiver \
                  -c channel -f value | \
                grep alarm_url | \
                sed -e "s/.*\(http.*V\=1\).*/\1/"`
