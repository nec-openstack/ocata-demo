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

docker run -d --name gitlab-runner \
    --restart always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /YOURVOLUME:/YOURVOLUME \
    \
    --env='CI_SERVER_URL=http://192.168.204.21:10080/ci'  \
    --env='REGISTRATION_TOKEN=oecQKhyCMcnjnHg73nty' \
    --env='RUNNER_NAME=YOURRUNNER'  \
    --env='RUNNER_EXECUTOR=docker' \
    --env='DOCKER_IMAGE=YOUR:IMAGE' \
    --env='DOCKER_NETWORK_MODE=YOURNETWORK' \
    --env='DOCKER_EXTRA_HOSTS=your.gitlab.example.com:10.0.0.5' \
    --env="DOCKER_VOLUMES=/ci" \
    --env="DOCKER_PRIVILEGED=true" \
    \
    --privileged \
    yuanying/gitlab-runner:latest

docker service create --name gitlab-runner \
    --mode global \
    --mount type=bind,target=/var/run/docker.sock,source=/var/run/docker.sock \
    --env='CI_SERVER_URL=http://192.168.204.21:10080/ci'  \
    --env='REGISTRATION_TOKEN=oecQKhyCMcnjnHg73nty' \
    --env='RUNNER_NAME=YOURRUNNER'  \
    --env='RUNNER_EXECUTOR=docker' \
    --env='DOCKER_IMAGE=ruby:2.1' \
    --env='DOCKER_NETWORK_MODE=host' \
    --env="DOCKER_VOLUMES=/ci" \
    --env="DOCKER_PRIVILEGED=true" \
    --network ingress \
    gitlab/gitlab-runner:latest

docker run --name gitlab-ci-multi-runner -d --restart=always \
  -v /var/run/docker.sock:/var/run/docker.sock \
  --env='CI_SERVER_URL=http://192.168.204.21:10080/ci' \
  --env='RUNNER_TOKEN=oecQKhyCMcnjnHg73nty' \
  --env='RUNNER_DESCRIPTION=Runner' --env='RUNNER_EXECUTOR=docker' \
  --privileged \
  sameersbn/gitlab-ci-multi-runner:1.1.4-4

docker exec -ti gitlab-runner.0.0brt1gztb1o8tlsxrwgvf5ovg gitlab-runner register \
  -n -u "http://192.168.204.21:10080/ci" -r "oecQKhyCMcnjnHg73nty" \
  --name "RUNNER" --executor "docker" \
  --docker-privileged --docker-image ruby:2.2


ssh://git@192.168.204.21:10022/root/demo.git
