#!/bin/bash
#
# add user to sudoers
#

if [[ -z ${2} ]]; then
    echo "${0} <user> <group>"
    exit 1
fi

source $(dirname ${0})/../env

user=${1}
group=${2}
opt=${3}

echo "${user} ALL=(ALL) NOPASSWD: ALL" | tee ${opt} /etc/sudoers.d/${group}
