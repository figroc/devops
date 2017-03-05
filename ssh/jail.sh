#!/bin/bash
#
# setup ssh jail
#
# Usage:
#     jail.sh setup
#     jail.sh crew [user] [role]
#     jail.sh serv [role] [user]
#     jail.sh esc crew [user]
#

# source ${BASH_SOURCE%/*}/vars.sh
jail='/var/jail'
gate='/etc/ssh/gate'
pubs='https://raw.githubusercontent.com/figroc/devops/master/pub'

# command switch
case $1 in
    setup)
        cmds='bash sh'
        cmdu='ssh scp sftp rssh'
        libu='openssh/sftp-server rssh/rssh_chroot_helper'

        # tools
        if apt-get install rssh; then
            sed -i '/^# chrootpath = .*/s@@chrootpath = '${jail}'@' /etc/rssh.conf
        fi
        if wget -O /sbin/l2chroot https://www.cyberciti.biz/files/lighttpd/l2chroot.txt; then
            sed -i '/^BASE=.*/s@@BASE="'${jail}'"@' /sbin/l2chroot
            chown root:root /sbin/l2chroot
            chmod +x /sbin/l2chroot
        fi

        # dirs
        mkdir -p ${jail}/{dev,etc,lib,lib64,usr,bin,home}
        mkdir -p ${jail}/usr/{bin,lib}
        mkdir -p ${jail}/usr/etc/ssh
        mkdir -p ${jail}/usr/lib/{openssh,rssh}
        chown root:root ${jail}
        chmod go-w ${jail}
        chmod o-r ${jail} ${jail}/home

        # devices
        mknod -m 622 ${jail}/dev/console c 5 1
        mknod -m 666 ${jail}/dev/null c 1 3
        mknod -m 666 ${jail}/dev/zero c 1 5
        mknod -m 666 ${jail}/dev/ptmx c 5 2
        mknod -m 666 ${jail}/dev/tty c 5 0
        mknod -m 444 ${jail}/dev/random c 1 8
        mknod -m 444 ${jail}/dev/urandom c 1 9
        chown root:tty ${jail}/dev/{console,ptmx,tty}
        ln -s /proc/self/fd ${jail}/dev/fd
        ln -s /proc/self/fd/0 ${jail}/dev/stdin
        ln -s /proc/self/fd/1 ${jail}/dev/stdout
        ln -s /proc/self/fd/2 ${jail}/dev/stderr
        ln -s /proc/kcore ${jail}/dev/core
        mkdir -p ${jail}/dev/{pts,shm}
        mount -vt devpts -o gid=4,mode=620 none ${jail}/dev/pts
        mount -vt tmpfs none ${jail}/dev/shm

        # files
        cp -ar /etc/ld.so.conf.d ${jail}/etc/
        cp /etc/ld.so.cache ${jail}/etc/
        cp /etc/ld.so.conf ${jail}/etc/
        cp /etc/resolv.conf ${jail}/etc/
        cp /etc/hosts ${jail}/etc/
        touch ${jail}/etc/{group,passwd}
        cp /etc/nsswitch.conf ${jail}/etc/
        sed -i '/^group:.*/s/compat/files/' ${jail}/etc/nsswitch.conf
        sed -i '/^passwd:.*/s/compat/files/' ${jail}/etc/nsswitch.conf
        mkdir -p ${jail}/lib/x86_64-linux-gnu
        cp /lib/x86_64-linux-gnu/libnss_* ${jail}/lib/x86_64-linux-gnu/
        cp -ar /lib/terminfo ${jail}/lib/

        # group
        if addgroup jail; then
            sed -i '/^jail:.*/d' ${jail}/etc/group
            grep '^jail:' /etc/group | tee -a ${jail}/etc/group
        fi

        # bin
        for cmd in ${cmds}; do
            cp /bin/${cmd} ${jail}/bin/
            l2chroot /bin/${cmd}
        done
        for cmd in ${cmdu}; do
            cp /usr/bin/${cmd} ${jail}/usr/bin/
            l2chroot /usr/bin/${cmd}
        done
        for cmd in ${libu}; do
            cp /usr/lib/${cmd} ${jail}/usr/lib/${cmd}
            l2chroot /usr/lib/${cmd}
        done
        ;;

    crew)
        user=$2
        role=$3

        mkdir -p ${gate}/servs
        mkdir -p ${gate}/crews

        if addgroup crews; then
            sed -i '/^crews:.*/d' ${jail}/etc/group
            grep '^crews:' /etc/group | tee -a ${jail}/etc/group
        fi

        if adduser --disabled-password --gecos '' --home ${jail}/home/${user} ${user}; then
            sed -i '/^'${user}':.*/s@:'${jail}'@:@' /etc/passwd
            chmod -R g+rw ${jail}/home/${user}
            wget -O ${gate}/crews/${user}.pub ${pubs}/${user}.pub
            chown ${user}:${user} ${gate}/crews/${user}.pub
            sed -i '/^'${user}':.*/d' ${jail}/etc/passwd
            sed -i '/^'${user}':.*/d' ${jail}/etc/group
            grep '^'${user}':' /etc/passwd | tee -a ${jail}/etc/passwd
            grep '^'${user}':' /etc/group | tee -a ${jail}/etc/group
        fi

        if adduser --disabled-password --gecos '' --home ${jail}/home/${user} \
                --force-badname --ingroup ${role} ${user}.${role}; then
            sed -i '/^'${user}'\.'${role}':.*/s@:'${jail}'@:@' /etc/passwd
            addgroup ${role}
            usermod -a -G jail,crews,${role} ${user}.${role}
            sed -i '/^'${user}'\.'${role}':.*/d' ${jail}/etc/passwd
            sed -i '/^jail:.*/d' ${jail}/etc/group
            sed -i '/^crews:.*/d' ${jail}/etc/group
            sed -i '/^'${role}':.*/d' ${jail}/etc/group
            grep '^'${user}'\.'${role}':' /etc/passwd | tee -a ${jail}/etc/passwd
            grep '^jail:' /etc/group | tee -a ${jail}/etc/group
            grep '^crews:' /etc/group | tee -a ${jail}/etc/group
            grep '^'${role}':' /etc/group | tee -a ${jail}/etc/group
        fi
        ;;

    serv)
        role=$2
        user=$3

        if adduser --disabled-password --gecos '' --home ${jail}/home/${role} ${role}; then
            sed -i '/^'${role}':.*/s@:'${jail}'@:@' /etc/passwd
            usermod -a -G jail ${role}
            sed -i '/^'${role}':.*/d' ${jail}/etc/passwd
            sed -i '/^jail:.*/d' ${jail}/etc/group
            sed -i '/^'${role}':.*/d' ${jail}/etc/group
            grep '^'${role}':' /etc/passwd | tee -a ${jail}/etc/passwd
            grep '^jail:' /etc/group | tee -a ${jail}/etc/group
            grep '^'${role}':' /etc/group | tee -a ${jail}/etc/group
        fi
        if wget -O ${gate}/sys/${user}.pub ${pubs}/${user}.pub; then
            chown ${role}:${role} ${gate}/sys/${user}.pub
        fi
        ;;

    agent)
        adir=${jail}${gate}/sys

        case $2 in
            key)
                mkdir -p ${adir}
                if [ ! -f ${adir}/agent.id ]; then
                    ssh-keygen -t rsa -b 4096 -N '' -C 'agent' ${adir}/agent
                    mv ${adir}/agent ${adir}/agent.id
                    chmod a+r ${adir}/agent.id
                fi
                ;;
            cp2)
                svr=$3
                if [ ! -z ${svr} ]; then
                    scp ${adir}/agent.pub ${svr}:${adir}/${HOSTNAME}.pub
                fi
                ;;
            *)
                ;;
        esac
        ;;

    esc)
        case $2 in
            crew)
                user=$3

                mkdir -p ${gate}/crews
                addgroup crews
                if adduser --disabled-password --gecos '' ${user}; then
                    usermod -a -G crews ${user}
                    wget -O ${gate}/crews/${user}.pub ${pubs}/${user}.pub
                    chown ${user}:${user} ${gate}/crews/${user}.pub
                fi
                ;;

            *)
                ;;
        esac
        ;;

    *)
        ;;
esac
