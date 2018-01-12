#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../env

while [[ -z "${R_SERVER}" ]]; do read -p "Gitlab coordinator: " R_SERVER; done
while [[ -z "${R_TOKENS}" ]]; do read -p "Registration token: " R_TOKENS; done
gitlab-runner register -n \
  -u ${R_SERVER} -t ${R_TOKENS} \
  --executor docker --docker-privileged --docker-image alpine \
  --docker-volumes /etc/docker/certs.d:/etc/docker/certs.d:ro \
  --docker-volumes /var/file/inn:/var/file/inn:rw && \
awk -i inplace \
  'FNR==NR{if(/^\s+executor\s+=\s+"docker"$/)p=NR;next}1;FNR==p{print"  environment = [\"DOCKER_DRIVER=overlay2\"]"}' \
  /etc/gitlab-runner/config.toml /etc/gitlab-runner/config.toml
