
GITLAB_CI_MULTI_RUNNER_DATA_DIR="/etc/gitlab-runner"
RANDOM_STRING=`cat /dev/urandom | base64 | fold -w 10 | head -n 1`
RUNNER_DESCRIPTION=${RUNNER_DESCRIPTION:-"Runner-${RANDOM_STRING}"}
RUNNER_EXECUTOR=${RUNNER_EXECUTOR:-"docker"}
DOCKER_IMAGE=${DOCKER_IMAGE:-"ruby:2.2"}

configure_ci_runner() {
  if [[ ! -e ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml ]]; then
    /usr/bin/gitlab-runner register --config ${GITLAB_CI_MULTI_RUNNER_DATA_DIR}/config.toml \
      -n -u "${CI_SERVER_URL}" -r "${RUNNER_TOKEN}" \
      --name "${RUNNER_DESCRIPTION}" --executor "${RUNNER_EXECUTOR}" \
      --docker-privileged --docker-image "${DOCKER_IMAGE}"
  fi
}
configure_ci_runner

exec /usr/bin/gitlab-runner "$@"
