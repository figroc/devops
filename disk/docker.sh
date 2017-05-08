#!/bin/bash
#
# docker storage setup
#

mnt='/var/data/mnt/docker'

usermod -G docker -a devops
systemctl stop docker
if mkdir -p ${mnt}; then
    chown root:root ${mnt}
    chmod go-rw ${mnt}
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
