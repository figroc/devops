#!/bin/bash -e

function z_err() {
    if [[ -z ${2} ]]; then echo ${1} 1>&2; exit 1; fi
}

function s_rm() {
    if [[ -f ${1} ]]; then sudo rm -f ${1}; fi
}

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1}; z_err "user not specified" ${usr};
hot=${2};
cmd=${args[0]}; z_err "no command specified" ${cmd};

case ${cmd} in
    ?)
        echo "box <devel|paddle>: reload devel docker"
        echo "box status: list running devel docker"
        ;;
    box)
        z_err "no host specified" ${hot};
        docker=${args[1]}; z_err "no target specified" ${docker};
        if [[ "${docker}" == "status" ]]; then
            ssh -i /etc/ssh/gate/sys/agent.id devops@${hot} \
                docker ps -f "name=${usr}-" 2>/dev/null
        else
            if [[ "${docker}" == "devel" ]]; then
                docker="client"
            elif [[ "${docker}" != "paddle" ]]; then
                z_err "unsupported target: ${docker}"
            fi
            ssh -i /etc/ssh/gate/sys/agent.id devops@${hot} \
                /home/devops/docker/${docker}/${usr}.sh
        fi
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
