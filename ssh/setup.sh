#!/bin/bash
#
# setup ssh for role
#

if [ -z ${1} ]; then
    echo ${0}' <role>'
    exit 1
fi

source $(dirname ${0})/../.env
mkdir -p ${gate}

if [ -f $(dirname ${0})/ssh_config ]; then
    cat $(dirname ${0})/ssh_config | tee -a /etc/ssh/sshd_config
fi
if [ -f $(dirname ${0})/sshd_config ]; then
    cat $(dirname ${0})/sshd_config | tee -a /etc/ssh/sshd_config
fi

role=$(dirname ${0})/${1}
if [ -f ${role}/akc.sh ]; then
    cp ${role}/akc.sh ${gate}/
fi
if [ -d ${role}/roles ]; then
    cp -r ${role}/roles ${gate}/
fi
if [ -f ${role}/ssh_config ]; then
    cat ${role}/ssh_config | tee -a /etc/ssh/ssh_config
fi
if [ -f ${role}/sshd_config ]; then
    cat ${role}/sshd_config | tee -a /etc/ssh/sshd_config
fi

service ssh reload
