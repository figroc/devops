#!/bin/bash -e
#
# docker nvidia setup
#

source $(dirname ${0})/../env

if dpkg -s nvidia-docker2 >/dev/null 2>&1; then
  apt-get purge -y nvidia-docker2
fi

if ! dpkg -s nvidia-384 >/dev/null 2>&1; then
  add-apt-repository multiverse
  add-apt-repository ppa:graphics-drivers
  apt-get update && apt-get install -y \
    mesa-common-dev \
    nvidia-384 \
    nvidia-modprobe
  shutdown -r now
fi

if ! dpkg -s nvidia-docker >/dev/null 2>&1; then
  wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
  dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb
  service nvidia-docker start
fi

nvidia-docker run --rm nvidia/cuda nvidia-smi
