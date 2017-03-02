#!/bin/bash
#
# setup user for service
#
# Usage: 
#   serv.sh name home
#

adduser --home $2 --disabled-password --gecos '' $1
sed -i '/^'$1':.*/s@:/home/'$1':@:'$2':@' /etc/passwd

