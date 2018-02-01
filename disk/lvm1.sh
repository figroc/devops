#!/bin/bash -e
#
# lvm disk setup
#

if [[ ${#} < 3 ]]; then
    echo "${0} <init|expand> sd-seq [...]"
    exit 1
fi

apt-get update && apt-get install -y lvm

source $(dirname ${0})/../env
source $(dirname ${0})/imount

cmd=${1}
shift

rno=${#}
while ((${#})); do
    rsd="${rsd} /dev/${1}"
    shift
done
pvcreate ${rsd}

if [[ "${cmd}" == "init" ]]; then
    vgcreate vg0 ${rsd}
    lvcreate -l 100%FREE -n lv0 vg0
    partprobe /dev/vg0/lv0
    sleep 2
    imount /dev/vg0/lv0
else
    vgextend vg0 ${rsd}
    lvresize -l 100%FREE -r vg0/lv0
    partprobe /dev/vg0/lv0
    sleep 2
fi
