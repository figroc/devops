#!/bin/bash -e
#
# raid0 disk setup
#

if [[ ${#} < 2 ]]; then
    echo "${0} part-seq ..."
    exit 1
fi

apt-get update && apt-get install -y mdadm

source $(dirname ${0})/../env
source $(dirname ${0})/imount

rno=${#}
while ((${#})); do
    sgdisk -o -N1 -t1:fd00 /dev/${1}
    partprobe /dev/${1}
    rsd="${rsd} /dev/${1}1"
    shift
done
sleep 2

if mdadm --create --verbos /dev/md0 --level=stripe \
    --raid-devices=${rno} ${rsd}; then
    imount /dev/md0
    mdadm --detail --scan | tee -a /etc/mdadm/mdadm.conf
fi
