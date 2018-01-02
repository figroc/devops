#!/bin/bash -e
#
# single disk setup
#

if [[ ${#} < 1 ]]; then
    echo "${0} disk"
    exit 1
fi

source $(dirname ${0})/../env

dsk="/dev/${1}"
sgdisk -e -d1 -N1 ${dsk}
partprobe ${dsk}

dsk="${dsk}1"
resize2fs ${dsk}
