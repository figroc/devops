#!/bin/bash -e
#
# setup common tools on target host
#

if [[ -z ${1} ]]; then
    echo ${0}' <target>'
    exit 1
fi

source $(dirname ${0})/../env

git clone ${repo}
sudo apt-get update
sudo apt-get -y install tree plzip
