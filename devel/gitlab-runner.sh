#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../.env

gitlab-runner register -n --locked false \
  -u ${1:?gitlab coordinator} -r ${2:?registration token} \
  --executor docker \
  --docker-privileged \
  --docker-image alpine \
  --docker-disable-cache \
  --env "GIT_SUBMODULE_STRATEGY=recursive" \
  --docker-helper-image deepro.io/gitlab/gitlab-runner-helper \
  --pre-build-script "service docker start"
