#!/bin/bash
#
# allow user pub key for service representative
#
# Usage: 
#   alow.sh serv user
#

gate='/var/gate'

wget -O ${gate}/sys/$2.pub https://raw.githubusercontent.com/figroc/devops/master/pub/$2.pub
chown $1:$1 ${gate}/sys/$2.pub
