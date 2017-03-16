#!/bin/bash
#
# sshfs mount uitility
#

gate='/etc/ssh/gate'
own='devops'
mnt='/var/sftp'

case $1 in
    setup)
        apt-get install sshfs
        sed -i '/#user_allow_other/s/#//' /etc/fuse.conf

        mkdir -p ${mnt}
        touch ${mnt}/WARNING
        chown ${own}:${own} ${mnt}

        sed -i '/sshfs sftp@sftp: .*/d' /etc/rc.local
        sed -i '/exit 0/d' /etc/rc.local
        echo "sshfs sftp@sftp: ${mnt} -o allow_other,reconnect,nonempty,"\
             "IdentityFile=${gate}/sys/agent.id " >> /etc/rc.local
        echo "exit 0" >> /etc/rc.local
        ;;

    mount)
        sshfs sftp@sftp: ${mnt} -o allow_other,reconnect,nonempty \
              -o IdentityFile=${gate}/sys/agent.id
        ;;

    umount)
        fusermount -u ${mnt}
        ;;

    *)
        echo 'sftpfs.sh [ setup | mount | umount ]'
        ;;
esac
