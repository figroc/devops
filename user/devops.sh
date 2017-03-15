#!/bin/bash
#
# add pub key for devops
#

user=$1
pubs='https://raw.githubusercontent.com/figroc/devops/master/pub'

wget ${pubs}/${user}.pub -O - | tee -a ~/.ssh/authorized_keys

