#!/bin/bash -e
#
# docker nvidia setup
#

source $(dirname ${0})/../env

docker volume ls -q -f driver=nvidia-docker | \
    xargs -r -I{} -n1 docker ps -q -a -f volume={} | \
    xargs -r docker rm -f
apt-get purge -y nvidia-docker

wget -P /tmp http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.1.85-1_amd64.deb
dpkg -i /tmp/cuda-repo-*.deb && rm /tmp/cuda-repo-*.deb
apt-key adv --fetch-keys http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
apt-get update && apt-get install -y \
    cuda

apt-key adv --fetch-keys https://nvidia.github.io/nvidia-docker/gpgkey
wget -P /etc/apt/sources.list.d https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list
apt-get update && apt-get install -y \
    nvidia-docker2
pkill -SIGHUP dockerd

docker run --runtime=nvidia --rm nvidia/cuda nvidia-smi
