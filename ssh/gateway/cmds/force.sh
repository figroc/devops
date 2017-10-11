#!/bin/bash -e

function z_err() {
    if [[ -z ${2} ]]; then echo ${1} 1>&2; exit 1; fi
}

function s_rm() {
    if [[ -f ${1} ]]; then sudo rm -f ${1}; fi
}

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1}; z_err "user not specified" ${usr};
cmd=${args[0]}; z_err "no command specified" ${cmd};

case ${cmd} in
    ?)
        echo "box <devel|paddle>: reload devel docker"
        echo "ban <user> [role]: disable user access"
        ;;
    box)
        devel=${1}; z_err "not host specified" ${devel};
        docker=${args[1]}; z_err "no target specified" ${docker};
        ssh -q -i /etc/ssh/gate/sys/agent.id devops@${devel} \
            /home/devops/docker/load.sh ${usr} ${docker}
        ;;
    ban)
        if [[ ! ${usr} =~ ^(chenp|yaxin|byzhang)$ ]]; then
            z_err "forbidden"
        fi
        user=${args[1]}; z_err "no user specified" ${user};
        role=${args[2]};
        if [[ -z ${role} ]]; then
            s_rm /etc/ssh/gate/crews/${user}.pub
        fi
        if sudo userdel ${user}.${role} 2>/dev/null; then
            sudo sed -i "/^${user}.${role}:/d" /var/jail/etc/passwd
            sudo sed -i "s/\b${user}.${role}\b,\?//g;s/,$//g" /var/jail/etc/group
        fi
        ;;
    *)
        z_err "command not support"
        ;;
esac

echo "done"
