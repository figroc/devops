#!/bin/bash
#
# docker storage setup
#

mnt='/var/data/mnt'
dkr=${mnt}'/docker'

apt-get -y install docker.io
usermod -G docker -a devops

systemctl stop docker
if mkdir -p ${mnt}; then
    chown devops:devops ${mnt}
fi
if mkdir -p ${dkr}; then
    chown root:root ${dkr}
    chmod go-rw ${dkr}
fi
(   echo '{'
    echo '  "graph": "'${mnt}'",'
    echo '  "live-restore": true,'
    echo '  "registry-mirrors":'
    echo '      ["https://f62945bb.mirror.aliyuncs.com"]'
    echo '  }'
    echo '}'
) | tee /etc/docker/daemon.json
systemctl start docker
service docker restart
