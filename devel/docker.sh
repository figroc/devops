#!/bin/bash

apt-get install docker.io
cat >/etc/docker/daemon.json <<EOF
{
  "graph": "/mnt/docker",
  "live-restore": true,
  "registry-mirrors": ["https://f62945bb.mirror.aliyuncs.com"]
}
EOF
service docker restart
usermod -aG docker devops
