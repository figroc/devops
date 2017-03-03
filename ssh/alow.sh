#!/bin/bash
#
# allow user pub key for service representative
#
# Usage: 
#   alow.sh user
#

gate='/etc/ssh/gate'

wget -O ${gate}/sys/$1.pub https://raw.githubusercontent.com/figroc/devops/master/pub/$1.pub
