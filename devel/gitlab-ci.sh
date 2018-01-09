#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../env
cert=$(dirname ${0})/../cert/server/asset.ca.crt

curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
cat > /etc/apt/preferences.d/pin-gitlab-runner.pref <<EOF
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF
apt-get install gitlab-runner

read -p "Gitlab coordinator: " R_SERVER
read -p "Registration token: " R_TOKENS
read -p "Runner description: " R_REMARK
( echo ${R_SERVER}
  echo ${R_TOKENS}
  echo ${R_REMARK}
  echo ''
  echo 'true'
  echo 'false'
  echo 'docker'
  echo 'alpine'
) | gitlab-runner register
