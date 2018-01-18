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
sgdisk -o -N1 -t1:8300 ${dsk}
partprobe ${dsk}

dsk="${dsk}1"
sleep 2
mkfs.ext4 -v -m .1 -b 4096 ${dsk}

uid=$(blkid ${dsk} | grep -o ': UUID="[^"]*"')
uid=${uid:2}
uid=${uid//\"/}
echo ${uid}$'\t'${data}$'\text4\tdefaults\t0\t2'\
    | tee -a /etc/fstab

if mkdir ${data} 2> /dev/null; then
    touch ${data}/WARNING
    chown ${devops}:${devops} ${data}
    mount ${data}
    chown ${devops}:${devops} ${data}
fi
