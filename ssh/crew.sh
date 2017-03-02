#!/bin/bash
#
# setup user for crews
#
# Usage: 
#   crew.sh
#   crew.sh user
#   crew.sh user serv
#

if [ $# -eq 0 ]; then
    addgroup crews
    mkdir -p /var/servs
    mkdir -p /var/crews
elif [ $# -eq 1 ]; then
    addgroup $1
    wget -O /var/crews/$1.pub https://raw.githubusercontent.com/figroc/devops/master/pub/$1.pub
elif [ $# -eq 2 ]; then
    adduser --home /home/jail/home/$1 --ingroup $1 --disabled-password --gecos '' --force-badname $1.$2
    usermod -a -G crews,jail $1.$2
    < /etc/passwd \
        sed '/^'$1'\.'$2':.*/s@/home/'$1'\.'$2'@/home/jail/home/'$1'@' \
        > /etc/passwd
fi
