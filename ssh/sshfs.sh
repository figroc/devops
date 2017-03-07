#!/bin/bash
#
# sshfs mount uitility
#

gate='/etc/ssh/gate'

case $1 in
    setup)
        sudo apt-get install sshfs
        adduser devops fuse
        sed -i '/#user_allow_other[[:blank:]]*$/s/^#//' /etc/fuse.conf 
        ;;

    mount)
        mnt=$2
        if [ ! -z ${mnt} ]; then
            mknod -m 666 /dev/fuse c 10 229
            mkdir -p ${mnt}
            chown devops:devops ${mnt}
            sshfs -o allow_other,idmap=user,default_permissions,IdentityFile=${gate}/sys/agent.id \
                sftp@sftp: ${mnt} 
        fi
        ;;

    unmount)
        mnt=$2
        if [ ! -z ${mnt} ]; then
            unmount ${mnt}
        fi
        ;;

    *)
        ;;
esac
