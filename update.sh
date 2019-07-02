#!/bin/bash

cd ~/devops

DEBIAN_FRONTEND=noninteractive

b=$(git branch | grep '^\* ' | cut -d' ' -f2)
if [[ "${b}" != "master" ]]; then
    git checkout master
fi
git pull --rebase
if [[ "${b}" != "master" ]]; then
    git checkout ${b}
    git rebase
fi

if [[ "${1}" == "--with-docker" ]]; then
    with_docker="1"
    shift
fi

if [[ -n "${with_docker}" ]]; then
    sudo apt-mark unhold docker-ce
fi
sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get -y autoclean
if [[ -n "${with_docker}" ]]; then
    sudo apt-mark hold docker-ce
fi

if [[ -n "$(which pip3)" ]]; then
    sudo pip3 install -U pip
fi
if [[ -n "$(which docker-compose)" ]]; then
    sudo pip3 install -U docker-compose
fi

while ((${#} > 0)); do
    ssh -q ${1} ~/devops/update.sh ${with_docker:+--with-docker}
    shift
done
