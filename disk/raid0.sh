#!/bin/bash -e
#
# raid0 disk setup
#

if [[ ${#} < 2 ]]; then
    echo "${0} sd-seq [...]"
    exit 1
fi

apt-get update && apt-get install -y mdadm

source $(dirname ${0})/../env
source $(dirname ${0})/imount

rmd='md0'
rno=${#}; rsd=''
while ((${#})); do
    sgdisk -o -N1 -t1:fd00 /dev/${1}
    partprobe /dev/${1}
    rsd=${rsd}' /dev/'${1}'1'
    shift
done
sleep 2

if mdadm --create --verbos /dev/${rmd} --level=stripe \
    --raid-devices=${rno} ${rsd}; then
    imount /dev/${rmd}
    mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
fi
