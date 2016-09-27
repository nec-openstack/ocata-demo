# Install Docker compose

    $ sudo su -
    # curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose
    # chmod +x /usr/local/bin/docker-compose

# Install gitlab

    $ cd ocata-demo/gitlab
    $ # replace host name to actual host name
    $ export GITLAB_HOST=192.168.204.21
    $ sed -i "s/__GITLAB_HOST__/${GITLAB_HOST}/g" ./docker-compose.yml
    $ docker-compose up -d

# Run gitlab runner

    docker service create --name gitlab-runner \
      --mode global \
      --mount type=bind,target=/var/run/docker.sock,source=/var/run/docker.sock \
      --env='CI_SERVER_URL=http://192.168.204.21:10080/ci' \
      --env='REGISTRATION_TOKEN=oecQKhyCMcnjnHg73nty' \
      --env='RUNNER_EXECUTOR=docker' \
      --env='DOCKER_IMAGE=ruby:2.2' \
      --env='DOCKER_NETWORK_MODE=host' \
      --env="DOCKER_VOLUMES=/ci" \
      --env="DOCKER_PRIVILEGED=true" \
      --network ingress \
      --constraint 'node.role != manager' \
      yuanying/gitlab-runner
