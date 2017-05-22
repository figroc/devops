#!/bin/bash

if [ -z ${1} ]; then
    echo ${0}' <host>'
    exit 1
fi

host=${1}
scp -3 -r devel:/var/data/mnt/cloudbrain ${host}:/var/data/mnt
scp client.docker.lz ${host}:~
ssh ${host} "plzip -d client.docker.lz && docker load -i client.docker && rm client.docker"
