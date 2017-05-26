#!/bin/bash
#
# load devel docker on target host
#

if [ -z ${1} ]; then
    echo ${0}' <host>'
    exit 1
fi

source $(dirname ${0})/../env

host=${1}

scp -r devel:${dkr_cbs} ${host}:${dkr_mnt}
scp devel:~/client.docker.lz ${host}:~ && \
ssh ${host} "plzip -d client.docker.lz && docker load -i client.docker && rm client.docker"
