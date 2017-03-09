#!/bin/bash
#
# sshfs mount uitility
#

gate='/etc/ssh/gate'

case $1 in
    setup)
        sudo apt-get install sshfs
        sed -i '/#user_allow_other[[:blank:]]*$/s/^#//' /etc/fuse.conf 
        ;;

    mount)
        mnt=$2
        if [ ! -z ${mnt} ]; then
            mkdir -p ${mnt}
            chown devops:devops ${mnt}
            sshfs -o allow_other,reconnect,IdentityFile=${gate}/sys/agent.id \
                sftp@sftp: ${mnt} 
        fi
        ;;

    unmount)
        mnt=$2
        if [ ! -z ${mnt} ]; then
            umount ${mnt}
        fi
        ;;

    *)
        ;;
esac
