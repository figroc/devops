#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../env

curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | bash
cat > /etc/apt/preferences.d/pin-gitlab-runner.pref <<EOF
Explanation: Prefer GitLab provided packages over the Debian native ones
Package: gitlab-runner
Pin: origin packages.gitlab.com
Pin-Priority: 1001
EOF
apt-get install -y gitlab-ci-multi-runner=1.11.5
