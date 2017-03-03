#!/bin/bash
#
# setup ssh jail
#

# config
jail='/home/jail'
cmds='bash sh'
cmdu='ssh scp sftp rssh'
libs='openssh/sftp-server rssh/rssh_chroot_helper'

# tools
apt-get install rssh
sed -i '/^# chrootpath = .*/s@@chrootpath = '${jail}'@' /etc/rssh.conf
wget -O /sbin/l2chroot https://www.cyberciti.biz/files/lighttpd/l2chroot.txt
sed -i '/^BASE=.*/s@@BASE="'${jail}'"@' /sbin/l2chroot
chmod +x /sbin/l2chroot

# jail group
addgroup jail

# jail dir
mkdir -p ${jail}/{dev,etc,lib,lib64,usr,bin,home}
mkdir -p ${jail}/usr/{bin,lib}
mkdir -p ${jail}/usr/lib/{openssh,rssh}
chown root:root ${jail}
chmod go-w ${jail}
mknod -m 666 ${jail}/dev/null c 1 3
cp -ar /etc/ld.so.conf.d ${jail}/etc/
cp /etc/ld.so.cache ${jail}/etc/
cp /etc/ld.so.conf ${jail}/etc/
cp /etc/nsswitch.conf ${jail}/etc/
cp /etc/resolv.conf ${jail}/etc/
cp /etc/hosts ${jail}/etc/
cp -ar /lib/terminfo ${jail}/lib/

# allow commands
for cmd in ${cmds}; do
    cp /bin/${cmd} ${jail}/bin/
    l2chroot /bin/${cmd}
done
for cmd in ${cmdu}; do
    cp /usr/bin/${cmd} ${jail}/usr/bin/
    l2chroot /usr/bin/${cmd}
done
for cmd in ${libs}; do
    cp /usr/lib/${cmd} ${jail}/usr/lib/${cmd}
    l2chroot /usr/lib/${cmd}
done
