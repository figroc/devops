#!/bin/bash -e
#
# gitlab runner setup
#

source $(dirname ${0})/../env

apt-get remove -y gitlab-runner
rm -f /etc/apt/sources.list.d/runner_gitlab-runner.list

curl -fsSL https://packages.gitlab.com/install/repositories/runner/gitlab-ci-multi-runner/script.deb.sh | bash
apt-get install -y gitlab-ci-multi-runner=1.11.5
apt-mark hold gitlab-ci-multi-runner
#sed -ir '/^concurrent\s+=\s+1$/s/1/3/' /etc/gitlab-runner/config.toml

echo "0 6 * * 6 docker container prune -f && docker volume prune -f" >/etc/cron.d/gci
