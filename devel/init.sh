#!/bin/bash
#
# setup common tools on target host
#

if [[ -z ${1} ]]; then
    echo ${0}' <target>'
    exit 1
fi

source $(dirname ${0})/../env

host=${1}

ssh ${host} "sudo apt-get -y install tree plzip"
ssh ${host} "git clone ${repo}"
