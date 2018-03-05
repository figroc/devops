#!/bin/bash
#
# add pub key for devops
#

if [[ -z ${1} ]]; then
    echo "${0} <user>"
    exit 1
fi

source $(dirname ${0})/../env

user=${1}

cat ${rdir}/pub/${user}.pub | tee -a ~/.ssh/authorized_keys
