#!/bin/bash
#
# setup user for service representative
#
# Usage: 
#   serv.sh name
#

adduser --home /home/jail/home/$1 --disabled-password --gecos '' $1
usermod -a -G jail $1
