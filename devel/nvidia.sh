#!/bin/bash -e
#
# docker nvidia setup
#

source $(dirname ${0})/../env

add-apt-repository multiverse
add-apt-repository ppa:graphics-drivers
apt-get update
apt-get install -y nvidia-384 nvidia-modprobe mesa-common-dev

wget -P /tmp https://github.com/NVIDIA/nvidia-docker/releases/download/v1.0.1/nvidia-docker_1.0.1-1_amd64.deb
dpkg -i /tmp/nvidia-docker*.deb && rm /tmp/nvidia-docker*.deb

shutdown -r now
nvidia-docker run --rm nvidia/cuda nvidia-smi
