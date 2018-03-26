#!/bin/bash
#
# setup ssh jail
#
# Usage:
#     jail.sh setup [jail|gate]
#     jail.sh crew <user> <role>
#     jail.sh proj <proj> <user>
#     jail.sh role <role> [crew|proj] <user>
#     jail.sh agent [copy-to] [copy-from]
#     jail.sh esc [crew|role] <name>
#     jail.sh esc agent [copy-to] [copy-from]
#

source $(dirname ${0})/../.env

# functions
function chroot_cmds {
    local src=${1}
    shift
    while ((${#})); do
        cp ${src}/${1} ${jail}/${src}/
        l2chroot ${src}/${1}
        shift
    done
}

function shadow_home {
    local user=${1}
    local role=${2}
    if [[ -n "${role}" ]]; then
        local user="${user}\\.${role}"
    fi
    sed -i "/^${user}:.*/s@:${jail}@:@" /etc/passwd
}

function shadow_shell {
    local user=${1}
    local role=${2}
    if [[ -n "${role}" ]]; then
        local user="${user}\\.${role}"
    fi
    sed -i "/^${user}:.*/s@:/bin/bash\$@:/bin/true@" /etc/passwd
}

function shadow_user {
    local user=${1}
    local role=${2}
    if [[ -n "${role}" ]]; then
        local user="${user}\\.${role}"
    fi
    sed -i "/^${user}:.*/d" ${jail}/etc/passwd
    grep "^${user}:" /etc/passwd | tee -a ${jail}/etc/passwd
}

function shadow_group {
    while ((${#})); do
        sed -i "/^${1}:.*/d" ${jail}/etc/group
        grep "^${1}:" /etc/group | tee -a ${jail}/etc/group
        shift
    done
}

function update_pkey {
    local user=${1}
    local ownr=${2}
    if [[ -z "${ownr}" ]]; then
        local ownr=${user}
    fi
    if \cp ${rdir}/pub/${user}.pub ${gate}/crews/${user}.pub; then
        chown ${ownr}:${ownr} ${gate}/crews/${user}.pub
    fi
}

function update_jkey {
    local user=${1}
    local proj=${2}
    if \cp ${rdir}/pub/projs/${proj}/${user}.pub ${gate}/projs/${proj}/${user}.pub; then
        if grep "^${user}\\.${proj}:" /etc/passwd; then
            chown ${user}.${proj}:${proj} ${gate}/projs/${proj}/${user}.pub
        elif grep "^${proj}:" /etc/passwd; then
            chown ${proj}:${proj} ${gate}/projs/${proj}/${user}.pub
        fi
    fi
}

function genc_agent {
    local adir=${1}
    local cdst=${2}
    local csrc=${3}
    if sudo mkdir -p ${adir}; then
        sudo chown ${devops}:${devops} ${adir}
    fi
    if [[ ! -f ${adir}/agent.id ]]; then
        ssh-keygen -t rsa -b 4096 -N "" -C "agent" -f ${adir}/agent
        mv ${adir}/agent ${adir}/agent.id
        chmod a+r ${adir}/agent.id
    fi
    if [[ -n "${csrc}" ]]; then
        scp -3 ${devops}@${csrc}:${adir}/agent.pub ${devops}@${cdst}:${adir}/${csrc}.pub
    elif [[ -n "${cdst}" ]]; then
        scp ${adir}/agent.pub ${devops}@${cdst}:${adir}/${HOSTNAME}.pub
    fi
}

# command switch
case "${1}" in
    setup)
        case "${2}" in
            gate)
                mkdir -p ${gate}/{sys,crews,projs}
                \cp -r ${rdir}/ssh/gateway/{akc.sh,roles} ${gate}/
                echo                                >> ${gate}/../sshd_config
                cat ${rdir}/ssh/sshd_config         >> ${gate}/../sshd_config
                cat ${rdir}/ssh/gateway/sshd_config >> ${gate}/../sshd_config
                echo                                >> ${gate}/../ssh_config
                cat ${rdir}/ssh/gateway/ssh_config  >> ${gate}/../ssh_config
                chown ${devops}:${devops} ${gate}/sys
                if [[ -d "${jail}" ]]; then
                    mkdir -p ${jail}${gate}/sys
                    chown ${devops}:${devops} ${jail}${gate}/sys
                    \cp -r ${rdir}/ssh/gateway/ssh_config ${jail}${gate}/../
                    \cp -r ${rdir}/ssh/gateway/cmds       ${jail}${gate}/
                else
                    \cp -r ${rdir}/ssh/gateway/cmds ${gate}/
                fi
                service ssh reload
                ;;

            cmds)
                chroot_cmds ${3} ${4}
                ;;

            jail)
                cmds=( bash sh true false )
                cmdu=( dirname env ssh ssh-agent scp sftp rssh )
                libu=( openssh/sftp-server rssh/rssh_chroot_helper )

                # tools
                if apt-get install rssh; then
                    sed -i "/^# chrootpath = .*/s@@chrootpath = ${jail}@" /etc/rssh.conf
                fi
                if wget -O /sbin/l2chroot https://www.cyberciti.biz/files/lighttpd/l2chroot.txt; then
                    sed -i "/^BASE=.*/s@@BASE=\"${jail}\"@" /sbin/l2chroot
                    chown root:root /sbin/l2chroot
                    chmod +x /sbin/l2chroot
                fi

                # dirs
                mkdir -p ${jail}/{dev,etc,lib,lib64,usr,bin,home,tmp}
                mkdir -p ${jail}/etc/ssh
                mkdir -p ${jail}/usr/{bin,lib}
                mkdir -p ${jail}/usr/lib/{openssh,rssh}
                chown root:root ${jail}
                chmod go-rw ${jail}
                chmod o-r ${jail}/home
                chmod 777 ${jail}/tmp

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
                sed -i "/^group:.*/s/compat/files/" ${jail}/etc/nsswitch.conf
                sed -i "/^passwd:.*/s/compat/files/" ${jail}/etc/nsswitch.conf
                mkdir -p ${jail}/lib/x86_64-linux-gnu
                cp /lib/x86_64-linux-gnu/libnss_* ${jail}/lib/x86_64-linux-gnu/
                cp -ar /lib/terminfo ${jail}/lib/

                # group
                if addgroup jail; then
                    shadow_group jail
                fi

                # bin
                chroot_cmds /bin ${cmds[@]}
                chroot_cmds /usr/bin ${cmdu[@]}
                chroot_cmds /usr/lib ${libu[@]}
                ;;
        esac
        ;;

    crew)
        user=${2}
        role=${3}

        mkdir -p ${gate}/roles
        mkdir -p ${gate}/crews

        if addgroup crews; then
            shadow_group crews
        fi

        if [[ -n "${user}" ]]; then
            if addgroup ${user}; then
                shadow_group ${user}
            fi
            if adduser --disabled-password --gecos "" \
                --home ${jail}/home/${user} \
                --ingroup ${user} ${user}; then
                chmod -R g+rw ${jail}/home/${user}
                usermod -aG jail,crews ${user}
                shadow_home ${user}
                shadow_user ${user}
                shadow_group jail crews ${user}
            fi
            update_pkey ${user}
        fi

        if [[ -n "${role}" ]]; then
            if addgroup ${role}; then
                shadow_group ${role}
            fi
            if adduser --disabled-password --gecos "" \
                --home ${jail}/home/${user} \
                --ingroup ${user} --force-badname ${user}.${role}; then
                usermod -aG jail,crews,${role} ${user}.${role}
                shadow_home ${user} ${role}
                shadow_user ${user} ${role}
                shadow_group jail crews ${role}
            fi
        fi
        ;;

    proj)
        proj=${2}
        user=${3}

        if addgroup projs; then
            shadow_group projs
        fi

        if [[ -n "${proj}" ]]; then
            mkdir -p ${gate}/projs/${proj}
            if addgroup ${proj}; then
                shadow_group ${proj}
            fi
        fi

        if [[ -n "${user}" ]]; then
            if adduser --disabled-password --gecos "" \
                --home ${jail}/home/${proj} \
                --ingroup ${proj} --force-badname ${user}.${proj}; then
                chmod -R g+w ${jail}/home/${proj}
                usermod -aG jail,projs ${user}.${proj}
                shadow_home ${user} ${proj}
                shadow_shell ${user} ${proj}
                shadow_user ${user} ${proj}
                shadow_group jail projs ${proj}
            fi
            update_jkey ${user} ${proj}
        fi
        ;;

    remo)
        user=${2}
        role=${3}
        if [[ -n "${user}" ]]; then
            if [[ -z "${role}" ]]; then
                s_rm ${gate}/crews/${user}.pub
            elif userdel ${user}.${role} 2>/dev/null; then
                sed -i "/^${user}\\.${role}:/d" ${jail}/etc/passwd
                sed -i "s/\\b${user}\\.${role}\\b,\?//g;s/,$//g" ${jail}/etc/group
            fi
        fi
        ;;

    role)
        role=${2}
        if [[ -n "${role}" ]]; then
            if adduser --disabled-password --gecos "" \
                --home ${jail}/home/${role} ${role}; then
                usermod -aG jail ${role}
                shadow_home ${role}
                shadow_user ${role}
                shadow_group jail ${role}
            fi
        fi

        user=${4}
        if [[ -n "${user}" ]]; then
            case "${3}" in
                crew)
                    mkdir -p ${gate}/crews
                    update_pkey ${user} ${role}
                    ;;

                proj)
                    addgroup projs
                    if usermod -aG projs ${role}; then
                        shadow_group projs
                    fi
                    mkdir -p ${gate}/projs/${role}
                    update_jkey ${user} ${role}
                    ;;
            esac
        fi
        ;;

    agent)
        genc_agent ${jail}${gate}/sys ${2} ${3}
        ;;

    esc)
        case "${2}" in
            crew)
                user=${3}

                mkdir -p ${gate}/crews
                addgroup crews
                if [[ -n "${user}" ]]; then
                    if adduser --disabled-password --gecos "" ${user}; then
                        usermod -aG crews ${user}
                    fi
                    update_pkey ${user}
                fi
                ;;

            role)
                role=${3}

                if [[ -n ${role} ]]; then
                    adduser --disabled-password --gecos "" ${role}
                fi
                ;;

            agent)
                genc_agent ${gate}/sys ${3} ${4}
                ;;
        esac
        ;;
esac
