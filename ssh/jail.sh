#!/bin/bash
#
# setup ssh jail
#

# config
jail='/var/jail'
cmds='bash sh'
cmdu='ssh scp sftp rssh'
libu='openssh/sftp-server rssh/rssh_chroot_helper'

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
mkdir -p ${jail}/usr/etc/ssh
mkdir -p ${jail}/usr/lib/{openssh,rssh}
chown root:root ${jail}
chmod go-w ${jail}
chmod o-r ${jail} ${jail}/home

# jail device
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

# jail prerequisite file
cp -ar /etc/ld.so.conf.d ${jail}/etc/
cp /etc/ld.so.cache ${jail}/etc/
cp /etc/ld.so.conf ${jail}/etc/
cp /etc/resolv.conf ${jail}/etc/
cp /etc/hosts ${jail}/etc/
touch ${jail}/etc/group
touch ${jail}/etc/passwd
sed -i '/^jail:.*/d' ${jail}/etc/group
grep '^jail:' /etc/group | tee -a ${jail}/etc/group
cp /etc/nsswitch.conf ${jail}/etc/
sed -i '/^group:.*/s/compat/files/' ${jail}/etc/nsswitch.conf
sed -i '/^passwd:.*/s/compat/files/' ${jail}/etc/nsswitch.conf
mkdir -p ${jail}/lib/x86_64-linux-gnu
cp /lib/x86_64-linux-gnu/libnss_* ${jail}/lib/x86_64-linux-gnu/
cp -ar /lib/terminfo ${jail}/lib/

# jail ssh config
if [ ! -f ${jail}/etc/ssh/ssh_config ]; then
    cat >${jail}/etc/ssh/ssh_config <<EOL
Host sftp
    StrictHostKeyChecking no
    UserKnownHostsFile=/dev/null
EOL
fi

# jail binary
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
