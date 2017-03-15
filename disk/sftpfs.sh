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
        sed -i '/#user_allow_other[[:blank:]]*$/s/^#//' /etc/fuse.conf 
        ;;

    mount)
        mkdir -p ${mnt}
        chown ${own}:${own} ${mnt}
        sshfs -o allow_other,reconnect,IdentityFile=${gate}/sys/agent.id \
            sftp@sftp: ${mnt} 
        ;;

    umount)
        umount ${mnt}
        ;;

    *)
        echo 'sftpfs.sh [ setup | mount | umount ]'
        ;;
esac
