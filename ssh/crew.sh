#!/bin/bash
#
# setup user for crews
#
# Usage: 
#   crew.sh
#   crew.sh user
#   crew.sh user serv
#

jail='/home/jail'
gate='/var/gate'

if [ $# -eq 0 ]; then
    addgroup crews
    sed -i '/^crews:.*/d' ${jail}/etc/group
    grep '^crews:' /etc/group | tee -a ${jail}/etc/group
    mkdir -p ${gate}/servs
    mkdir -p ${gate}/crews
elif [ $# -eq 1 ]; then
    addgroup $1
    sed -i '/^'$1':.*/d' ${jail}/etc/group
    grep '^'$1':' /etc/group | tee -a ${jail}/etc/group
    wget -O ${gate}/crews/$1.pub https://raw.githubusercontent.com/figroc/devops/master/pub/$1.pub
elif [ $# -eq 2 ]; then
    adduser --home ${jail}/home/$1 --ingroup $1 --disabled-password --gecos '' --force-badname $1.$2
    sed -i '/^'$1'\.'$2':.*/s@:/home/'$1'\.'$2':@:/home/'$1':@' /etc/passwd
    sed -i '/^'$1'\.'$2':.*/d' ${jail}/etc/passwd
    grep '^'$1'\.'$2':' /etc/passwd | tee -a ${jail}/etc/passwd
    chmod -R g+rw ${jail}/home/$1
    addgroup $2
    usermod -a -G crews,jail,$2 $1.$2
    sed -i '/^jail:.*/d' ${jail}/etc/group
    sed -i '/^crews:.*/d' ${jail}/etc/group
    sed -i '/^'$1':.*/d' ${jail}/etc/group
    sed -i '/^'$2':.*/d' ${jail}/etc/group
    grep '^jail:' /etc/group | tee -a ${jail}/etc/group
    grep '^crews:' /etc/group | tee -a ${jail}/etc/group
    grep '^'$1':' /etc/group | tee -a ${jail}/etc/group
    grep '^'$2':' /etc/group | tee -a ${jail}/etc/group
fi
