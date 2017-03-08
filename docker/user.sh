#!/bin/bash
#
# enable docker user
#

user=$1
home='/var/data/home'
pubs='https://raw.githubusercontent.com/figroc/devops/master/pub'

mkdir -p ${home}
useradd -m -b ${home} -s /usr/sbin/nologin ${user}
gpasswd -a ${user} docker
mkdir -p ${home}/${user}/.ssh
wget -O ${home}/${user}/.ssh/authorized_keys ${pubs}/${user}.pub
