#!/bin/bash -e
#
# docker storage setup
#

mirror="${1}"

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
if mkdir -p ${dkr_dir}; then
    chown root:root ${dkr_dir}
    chmod go-rw ${dkr_dir}
fi

(   echo '{'
    echo '  "data-root": "'${dkr_dir}'",'
    echo '  "log-opts": {'
    echo '    "max-size": "1g"'
    if [[ -n "${mirror}" ]]; then
        echo '  },'
        echo '  "registry-mirrors": ['
        echo '    "https://f62945bb.mirror.aliyuncs.com"'
        echo '  ]'
    else
        echo '  }'
    fi
    echo '}'
) | tee /etc/docker/daemon.json

if mkdir -p ${dkr_crt}; then
    chown root:root ${dkr_crt}
fi
cp ${cert} ${dkr_crt}/ca.crt
chown root:root ${dkr_crt}/ca.crt
chmod 644 ${dkr_crt}/ca.crt

usermod -G docker -a ${devops}
systemctl daemon-reload
systemctl start docker

apt-get -y install python-pip
pip install ${mirror:+-i https://mirrors.aliyun.com/pypi/simple} --upgrade pip
pip install ${mirror:+-i https://mirrors.aliyun.com/pypi/simple} --upgrade docker-compose
