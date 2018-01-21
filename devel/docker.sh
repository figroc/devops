#!/bin/bash -e
#
# docker storage setup
#

source $(dirname ${0})/../env
cert=$(dirname ${0})/../cert/server/asset.ca.crt

apt-get update
apt-get remove -y docker docker.io
apt-get install -y curl apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

apt-get update
apt-get -y install docker-ce
apt-mark hold docker-ce
systemctl stop docker

mkdir -p ${data}
if mkdir -p ${dkr_mnt}; then
    chown devops:devops ${dkr_mnt}
fi
if mkdir -p ${dkr_graf}; then
    chown root:root ${dkr_graf}
    chmod go-rw ${dkr_graf}
fi

(   echo '{'
    echo '  "data-root": "'${dkr_graf}'",'
    echo '  "log-opts": {'
    echo '    "max-size": "1g"'
    echo '  },'
    echo '  "registry-mirrors": ['
    echo '    "https://f62945bb.mirror.aliyuncs.com"'
    echo '  ]'
    echo '}'
) | tee /etc/docker/daemon.json

if mkdir -p ${dkr_reg}; then
    chown root:root ${dkr_reg}
fi
cp ${cert} ${dkr_reg}/ca.crt
chown root:root ${dkr_reg}/ca.crt
chmod 644 ${dkr_reg}/ca.crt

usermod -G docker -a ${devops}
systemctl daemon-reload
systemctl start docker

apt-get -y install python-pip
pip install --upgrade pip
pip install --upgrade docker-compose
