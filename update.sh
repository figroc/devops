#!/bin/bash

cd ~/devops

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
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove

while ((${#} > 0)); do
    ssh -q ${1} ~/devops/update.sh
    shift
done
