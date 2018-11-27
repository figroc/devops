#!/bin/bash -e
#
# lvm disk setup
#

if [[ ${#} < 2 ]]; then
    echo "${0} < init | expand > disk-seq ..."
    exit 1
fi

apt-get update && apt-get install -y lvm2

source $(dirname ${0})/../.env
source $(dirname ${0})/imount

cmd=${1}
shift

while ((${#})); do
    rsd="${rsd} /dev/${1}"
    shift
done
pvcreate ${rsd}

if [[ "${cmd}" == "init" ]]; then
    vgcreate vg0 ${rsd}
    lvcreate -l 100%FREE -n lv0 vg0
    imount /dev/vg0/lv0
else
    vgextend vg0 ${rsd}
    lvextend -l 100%VG -r /dev/vg0/lv0
fi
