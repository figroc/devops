#!/bin/bash
#
# setup user for crews
#
# Usage: 
#   crew.sh
#   crew.sh user
#   crew.sh user role
#

jail='/var/jail'
gate='/etc/ssh/gate'

if [ $# -eq 0 ]; then
    addgroup crews
    sed -i '/^crews:.*/d' ${jail}/etc/group
    grep '^crews:' /etc/group | tee -a ${jail}/etc/group
    mkdir -p ${gate}/servs
    mkdir -p ${gate}/crews
elif [ $# -eq 1 ]; then
    adduser --home ${jail}/home/$1 --disabled-password --gecos '' $1
    chmod -R g+rw ${jail}/home/$1
    sed -i '/^'$1':.*/s@:'${jail}'@:@' /etc/passwd
    sed -i '/^'$1':.*/d' ${jail}/etc/passwd
    sed -i '/^'$1':.*/d' ${jail}/etc/group
    grep '^'$1':' /etc/passwd | tee -a ${jail}/etc/passwd
    grep '^'$1':' /etc/group | tee -a ${jail}/etc/group
    wget -O ${gate}/crews/$1.pub https://raw.githubusercontent.com/figroc/devops/master/pub/$1.pub
elif [ $# -eq 2 ]; then
    adduser --home ${jail}/home/$1 --ingroup $1 --disabled-password --gecos '' --force-badname $1.$2
    sed -i '/^'$1'\.'$2':.*/s@:'${jail}'@:@' /etc/passwd
    sed -i '/^'$1'\.'$2':.*/d' ${jail}/etc/passwd
    grep '^'$1'\.'$2':' /etc/passwd | tee -a ${jail}/etc/passwd
    addgroup $2
    usermod -a -G jail,crews,$2 $1.$2
    sed -i '/^jail:.*/d' ${jail}/etc/group
    sed -i '/^crews:.*/d' ${jail}/etc/group
    sed -i '/^'$2':.*/d' ${jail}/etc/group
    grep '^jail:' /etc/group | tee -a ${jail}/etc/group
    grep '^crews:' /etc/group | tee -a ${jail}/etc/group
    grep '^'$2':' /etc/group | tee -a ${jail}/etc/group
fi
