#!/bin/bash
#
# ossfs mount uitility
#

mpoint=${2}
bucket=${3}
epoint=${4}
access=${5}

source $(dirname ${0})/../.env

case "${1}" in
    setup)
        rm -rf /tmp/ossfs.deb && \
        curl -fSL -o /tmp/ossfs.deb \
            https://github.com/aliyun/ossfs/releases/download/v1.80.5/ossfs_1.80.5_ubuntu16.04_amd64.deb && \
        apt-get update && \
        apt-get install -y gdebi-core && \
        gdebi /tmp/ossfs.deb && \
        rm -rf /tmp/ossfs.deb

        echo "${bucket}:${access}" > /etc/passwd-ossfs
        chmod 640 /etc/passwd-ossfs

        mkdir -p ${mpoint}
        touch ${mpoint}/WARNING
        chown ${devops}:${devops} ${mpoint}

        sed -i "/ossfs ${bucket} .*/d" /etc/rc.local
        sed -i "/exit 0/d" /etc/rc.local
        echo "ossfs ${bucket} ${mpoint} -ononempty,allow_other,url=${epoint}" >> /etc/rc.local
        echo "exit 0" >> /etc/rc.local
        ;&

    mount)
        ossfs ${bucket} ${mpoint} -ononempty,allow_other,url=${epoint}
        ;;

    umount)
        fusermount -u ${mpoint}
        ;;

    *)
        echo "${0} [ setup | mount | umount ]"
        exit 1
        ;;
esac
