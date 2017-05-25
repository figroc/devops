#!/bin/bash
#
# enable docker user
#

if [ -z ${1} ]; then
    echo ${0}' <user>'
    exit 1
fi

source $(dirname ${0})/../env

user=${1}
home=${data}'/home'

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

if mkdir -p /home/${user}; then
    chown ${user}:${user} /home/${user}
fi
if mount --bind ${home}/${user} /home/${user}; then
    echo ${home}/${user}$'\t'/home/${user}$'\tnone\tbind\t0\t0' \
        | tee -a /etc/fstab
fi
