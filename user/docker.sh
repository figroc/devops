#!/bin/bash
#
# enable docker user
#

user=$1
home='/var/data/home'
pubs='https://raw.githubusercontent.com/figroc/devops/master/pub'

if [ -z /etc/sudoers.d/docker ]; then
    mkdir -p /etc/sudoers.d
    echo '%docker  ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/docker
fi

mkdir -p ${home}
if useradd -m -b ${home} -s /usr/sbin/nologin ${user}; then
    gpasswd -a ${user} docker
fi

mkdir -p ${home}/${user}/.ssh
wget -O ${home}/${user}/.ssh/authorized_keys ${pubs}/${user}.pub

mkdir -p /home/${user}
if mount --bind ${home}/${user} /home/${user}; then
    echo ${home}/${user}$'\t'/home/${user}$'\tnone\tbind\t0\t0' \
        | tee -a /etc/fstab
fi
