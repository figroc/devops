#!/bin/bash -e
#
# raid0 disk setup
#

if [[ ${#} < 3 ]]; then
    echo "${0} md-seq sd-seq ..."
    exit 1
fi

apt-get update && apt-get install -y mdadm

source $(dirname ${0})/../env

rmd=${1}; shift
rno=${#}; rsd=''
while ((${#})); do
    (   echo o    # clear partition table
        echo Y    #   confirm
        echo n    # new partition
        echo      # default partition number 1
        echo      # default first sector
        echo      # default last sector
        echo fd00 # linux raid
        echo w    # write changes
        echo Y    #   confirm
    ) | gdisk /dev/${1}
    partprobe /dev/${1}
    rsd=${rsd}' /dev/'${1}'1'
    shift
done

if mdadm --create --verbos /dev/${rmd} --level=stripe \
    --raid-devices=${rno} ${rsd}; then
    mkfs.ext4 -v -m .1 -b 4096 /dev/${rmd}
    mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
    uid=$(blkid /dev/${rmd} | grep -o ': UUID="[^"]*"')
    uid=${uid:2}
    uid=${uid//\"/}
    echo ${uid}$'\t'${data}$'\text4\tdefaults\t0\t2'\
        | tee -a /etc/fstab

    mkdir -p ${data}
    touch ${data}/WARNING
    chown ${devops}:${devops} ${data}
    mount ${data}
    chown ${devops}:${devops} ${data}
fi
