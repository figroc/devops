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

sudo apt-get -y update
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove
sudo apt-get -y autoclean

if [[ -n "$(which pip)" ]]; then
    sudo pip install -U pip
fi

while ((${#} > 0)); do
    ssh -q ${1} ~/devops/update.sh
    shift
done
