#!/bin/bash
#
# setup sftp project dir
#

if [ -z ${1} ]; then
    echo ${0}' <project>'
    exit 1
fi

source $(dirname ${0})/../env

proj=${1}

chown -R root:root ${jail}/home/${proj}
chmod -R o-r ${jail}/home/${proj}

mkdir -p ${jail}/home/${proj}/data
mkdir -p ${jail}/home/${proj}/data/delivery
chown -R ${proj}:${proj} ${jail}/home/${proj}/data
chown -R sftp:sftp ${jail}/home/${proj}/data/delivery
chmod -R g+w ${jail}/home/${proj}/data
chmod -R a+r ${jail}/home/${proj}/data

mkdir -p ${jail}/data/projects/${proj}
if mount --bind ${jail}/home/${proj}/data ${jail}/data/projects/${proj}; then
    echo \
        ${jail}/home/${proj}/data$'\t'${jail}/data/projects/${proj}$'\tnone\tbind\t0\t0' \
        | tee -a /etc/fstab
fi
