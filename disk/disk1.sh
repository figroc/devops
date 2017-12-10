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
(   echo o    # clear partition table
    echo Y    #   confirm
    echo n    # new partition
    echo      # default partition number 1
    echo      # default first sector
    echo      # default last sector
    echo 8300 # linux filesystem
    echo w    # write changes
    echo Y    #   confirm
) | gdisk ${dsk}
partprobe ${dsk}
dsk="${dsk}1"

mkfs.ext4 -v -m .1 -b 4096 ${dsk}
uid=$(blkid ${dsk} | grep -o ': UUID="[^"]*"')
uid=${uid:2}
uid=${uid//\"/}
echo ${uid}$'\t'${data}$'\text4\tdefaults\t0\t2'\
    | tee -a /etc/fstab

mkdir -p ${data}
touch ${data}/WARNING
chown ${devops}:${devops} ${data}
mount ${data}
chown ${devops}:${devops} ${data}
