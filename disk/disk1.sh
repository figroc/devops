#!/bin/bash -e
#
# single disk setup
#

if [[ ${#} < 2 ]]; then
    echo "${0} <init|expand> disk"
    exit 1
fi

source $(dirname ${0})/../env
source $(dirname ${0})/imount

cmd="${1}"
dsk="/dev/${2}"
if [[ "${cmd}" == "init" ]]; then
    sgdisk -o -N1 -t1:8300 ${dsk}
else
    umount ${data}
    sgdisk e -d1 -N1 ${dsk}
fi

partprobe ${dsk}
sleep 2

dsk="${dsk}1"
if [[ "${cmd}" == "init" ]]; then
    imount ${dsk}
else
    resize2fs ${dsk}
    mount ${data}
fi
