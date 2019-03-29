#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../.env

while [[ -z "${R_SERVER}" ]]; do read -p "Gitlab coordinator: " R_SERVER; done
while [[ -z "${R_TOKENS}" ]]; do read -p "Registration token: " R_TOKENS; done
gitlab-runner register -n --locked false \
  --limit 1 --request-concurrency 1 \
  -u ${R_SERVER} -r ${R_TOKENS} \
  --executor docker --docker-privileged --docker-image alpine \
  --docker-helper-image deepro.io/gitlab/gitlab-runner-helper \
  --docker-volumes /etc/docker/daemon.json:/etc/docker/daemon.json:ro \
  --docker-volumes /var/file/inn:/var/file/inn:rw \
  --env "DOCKER_DRIVER=overlay2"
