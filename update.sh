#!/bin/bash

g='git -C ~/devops'
b=$(${g} branch | grep '^\* ' | cut -d' ' -f2)
if [[ "${b}" != "master" ]]; then
    ${g} checkout master
fi
${g} pull --rebase
if [[ "${b}" != "master" ]]; then
    ${g} checkout ${b}
    ${g} rebase
fi

sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt-get -y autoremove

while ((${#} > 0)); do
    ssh -q ${1} ~/devops/update.sh
    shift
done
