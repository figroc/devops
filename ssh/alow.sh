#!/bin/bash
#
# allow user pub key for service representative
#
# Usage: 
#   alow.sh serv user
#

jail='/home/jail'
gate='/var/gate'

wget -O - https://raw.githubusercontent.com/figroc/devops/master/pub/$2.pub \
    | tee -a ${gate}/sys/$1.pub
chown $1:$1 $1

adduser --home ${jail}/home/$1 --disabled-password --gecos '' $1
sed -i '/^'$1':.*/d' ${jail}/etc/passwd
grep '^'$1':' /etc/passwd | tee -a ${jail}/etc/passwd
usermod -a -G jail $1
sed -i '/^jail:.*/d' ${jail}/etc/group
sed -i '/^'$1':.*/d' ${jail}/etc/group
grep '^jail:' /etc/group | tee -a ${jail}/etc/group
grep '^'$1':' /etc/group | tee -a ${jail}/etc/group
