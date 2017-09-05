#!/bin/bash
#
# docker storage setup
#

source $(dirname ${0})/../env

apt-get update

apt-get -y install docker.io
usermod -G docker -a ${devops}

systemctl stop docker
if mkdir -p ${dkr_mnt}; then
    chown devops:devops ${dkr_mnt}
fi
if mkdir -p ${dkr_graf}; then
    chown root:root ${dkr_graf}
    chmod go-rw ${dkr_graf}
fi
(   echo '{'
    echo '  "graph": "'${dkr_graf}'",'
    echo '  "live-restore": true,'
    echo '  "registry-mirrors":'
    echo '      ["https://f62945bb.mirror.aliyuncs.com"]'
    echo '  }'
    echo '}'
) | tee /etc/docker/daemon.json
systemctl start docker
service docker restart

apt-get -y install python-pip
pip install --upgrade pip
pip install docker-compose
