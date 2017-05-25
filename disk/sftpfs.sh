#!/bin/bash
#
# sshfs mount uitility
#

source $(dirname ${0})/../env

case ${1} in
    setup)
        apt-get -y install sshfs
        sed -i '/#user_allow_other/s/#//' /etc/fuse.conf

        mkdir -p ${sftp}
        touch ${sftp}/WARNING
        chown ${devops}:${devops} ${sftp}

        sed -i '/sshfs sftp@sftp: .*/d' /etc/rc.local
        sed -i '/exit 0/d' /etc/rc.local
        echo "sshfs sftp@sftp: ${sftp} -o allow_other,reconnect,nonempty" \
             "-o IdentityFile=${gate}/sys/agent.id" >> /etc/rc.local
        echo "exit 0" >> /etc/rc.local
        ;;

    mount)
        sshfs sftp@sftp: ${sftp} -o allow_other,reconnect,nonempty \
              -o IdentityFile=${gate}/sys/agent.id
        ;;

    umount)
        fusermount -u ${sftp}
        ;;

    *)
        echo ${0}' [ setup | mount | umount ]'
        exit 1
        ;;
esac
