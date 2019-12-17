#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../.env

while [[ -z "${R_SERVER}" ]]; do read -p "Gitlab coordinator: " R_SERVER; done
while [[ -z "${R_TOKENS}" ]]; do read -p "Registration token: " R_TOKENS; done
gitlab-runner register -n --locked false \
  -u ${R_SERVER} -r ${R_TOKENS} \
  --executor docker --docker-privileged \
  --docker-image alpine \
  --env "GIT_SUBMODULE_STRATEGY=recursive" \
  --docker-helper-image deepro.io/gitlab/gitlab-runner-helper \
  --pre-build-script "service docker start"
