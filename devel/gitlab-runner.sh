#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../.env

gitlab-runner register -n \
  --locked=false \
  -u ${1:?gitlab coordinator} \
  -r ${2:?registration token} \
  --executor docker \
  --docker-privileged \
  --docker-image deepro.io/cloudbrain/devel:devel \
  --docker-helper-image deepro.io/gitlab/gitlab-runner-helper \
  --pre-build-script "rm -rf /var/lib/docker/* && service docker start && sleep 3" \
  --post-build-script "service docker stop && sleep 3 && rm -rf /var/lib/docker/*" \
  --env "GIT_SUBMODULE_STRATEGY=recursive"
