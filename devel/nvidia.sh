#!/bin/bash -e
#
# docker nvidia setup
#

source $(dirname ${0})/../.env

if dpkg -s nvidia-docker >/dev/null 2>&1; then
  docker volume ls -q -f driver=nvidia-docker | \
    xargs -r -I{} -n1 docker ps -q -a -f volume={} | \
    xargs -r docker rm -f
  apt-get purge -y nvidia-docker
fi

if ! dpkg -s cuda-drivers >/dev/null 2>&1; then
  apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/7fa2af80.pub
  wget -NP /tmp https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1604/x86_64/cuda-repo-ubuntu1604_9.2.88-1_amd64.deb
  dpkg -i /tmp/cuda-repo-*.deb && rm /tmp/cuda-repo-*.deb
  sed -i 's/ http:/ https:/' /etc/apt/sources.list.d/cuda.list
  apt-get update && apt-get install -y cuda-drivers && apt-mark hold cuda-drivers
  shutdown -r now
fi

if ! dpkg -s nvidia-docker2 >/dev/null 2>&1; then
  apt-key adv --fetch-keys https://nvidia.github.io/nvidia-docker/gpgkey
  wget -NP /etc/apt/sources.list.d https://nvidia.github.io/nvidia-docker/ubuntu16.04/amd64/nvidia-docker.list
  apt-get update && apt-get install -y nvidia-docker2 && apt-mark hold nvidia-docker2
  sed -i '$ d'      /etc/docker/daemon.json && \
  sed -i '$ s/$/,/' /etc/docker/daemon.json && \
  ( echo '  "default-runtime": "nvidia",'
    echo '  "runtimes": {'
    echo '    "nvidia": {'
    echo '      "path": "/usr/bin/nvidia-container-runtime",'
    echo '      "runtimeArgs": []'
    echo '    }'
    echo '  }'
  ) | tee -a /etc/docker/daemon.json && \
  sed -i '$ a}' /etc/docker/daemon.json
  pkill -SIGHUP dockerd
fi

docker run --rm nvidia/cuda nvidia-smi
