#!/bin/bash
#
# add pub key for devops
#

if [[ -z ${1} ]]; then
    echo ${0}' <user>'
    exit 1
fi

source $(dirname ${0})/../env

user=${1}

wget ${pubs}/${user}.pub -O - | tee -a ~/.ssh/authorized_keys
