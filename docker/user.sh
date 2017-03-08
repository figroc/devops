#!/bin/bash
#
# enable docker user
#

user=$1
pubs='https://raw.githubusercontent.com/figroc/devops/master/pub'

mkdir -p /var/data/home
useradd -m -b /var/data/home -s /usr/sbin/nologin ${user}
gpasswd -a ${user} docker
wget -O /var/data/home/${user}/.ssh/authorized_keys ${pubs}/${user}.pub
