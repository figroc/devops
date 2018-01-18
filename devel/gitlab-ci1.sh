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
apt-mark hold gitlab-ci-multi-runner
#sed -ir '/^concurrent\s+=\s+1$/s/1/3/' /etc/gitlab-runner/config.toml

echo "@daily docker container prune -f && docker volume prune -f" >/etc/cron.d/gci
