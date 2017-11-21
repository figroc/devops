#!/bin/bash -e
#
# setup common tools
#

source $(dirname ${0})/../env

if [ ! -f /etc/sysctl.d/60-elastic.conf ]; then
    echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/60-elastic.conf
    sudo sysctl -w vm.max_map_count=262144
fi

if ! grep deepro.io /etc/hosts; then
    echo "10.2.0.4  deepro.io" | sudo tee -a /etc/hosts
fi

if [ ! -d ~/${devops} ]; then
    git -C ~ clone ${repo}
fi

sudo apt-get update &&\
sudo apt-get -y install tree plzip zip
