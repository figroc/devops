#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../env

curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-runner/script.deb.sh | bash
cat > /etc/apt/preferences.d/pin-gitlab-runner.pref <<EOF
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF
apt-get install -y gitlab-runner

while [[ -z "${R_SERVER}" ]]; do read -p "Gitlab coordinator: " R_SERVER; done
while [[ -z "${R_TOKENS}" ]]; do read -p "Registration token: " R_TOKENS; done
( echo "${R_SERVER}"
  echo "${R_TOKENS}"
  echo ""
  echo ""
  echo "true"
  echo "false"
  echo "docker"
  echo "alpine"
) | gitlab-runner register
