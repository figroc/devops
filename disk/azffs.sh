#!/bin/bash
#
# azffs mount uitility
#

mpoint=${2}
bucket=${3}
epoint=${4}
access=${5}

source $(dirname ${0})/../.env

case "${1}" in
    setup)
        apt-get update
        apt-get install -y cifs-utils

        mkdir -p ${mpoint}
        touch ${mpoint}/WARNING
        chown ${devops}:${devops} ${mpoint}

        sed -i "\\^${mpoint}^d" /etc/fstab
        echo "//${epoint}/${bucket} ${mpoint} cif" \
             "vers=3.0,username=${access%:*},password=${access#*:},dir_mode=0777,file_mode=0777,sec=ntlmssp" \
             "0 0" >> /etc/fstab
        ;&

    mount)
        mount ${mpoint}
        ;;

    umount)
        umount ${mpoint}
        ;;

    *)
        echo "${0} [ setup | mount | umount ]"
        exit 1
        ;;
esac
