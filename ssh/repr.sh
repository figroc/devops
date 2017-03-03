#!/bin/bash
#
# setup user for service representative
#
# Usage: 
#   serv.sh name
#

jail='/var/jail'

adduser --home ${jail}/home/$1 --disabled-password --gecos '' $1
sed -i '/^'$1':.*/s@:'${jail}'@:@' /etc/passwd
sed -i '/^'$1':.*/d' ${jail}/etc/passwd
grep '^'$1':' /etc/passwd | tee -a ${jail}/etc/passwd
usermod -a -G jail $1
sed -i '/^jail:.*/d' ${jail}/etc/group
sed -i '/^'$1':.*/d' ${jail}/etc/group
grep '^jail:' /etc/group | tee -a ${jail}/etc/group
grep '^'$1':' /etc/group | tee -a ${jail}/etc/group
