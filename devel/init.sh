#!/bin/bash

if [ -z ${1} ]; then
    echo ${0}' <target>'
    exit 1
fi

host=${1}
ssh ${host} "sudo apt-get -y install docker.io plzip tree"
ssh ${host} "git clone https://github.com/figroc/devops.git"
