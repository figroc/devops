#!/bin/bash -e

source $(dirname $0)/env

function s_rm() {
    if [[ -f ${1} ]]; then sudo rm -f ${1}; fi
}

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1};       z_err "user not specified" ${usr};
cmd=${args[0]}; z_err "no command specified" ${cmd};

case ${cmd} in
    ?)
        echo "box <devel...>: reload devel docker"
        echo "box status: list running devel docker"
        ;;
    ban)
        if [[ ! ${usr} =~ ^(chenp|byzhang|yaxin)$ ]]; then
            z_err "forbidden"
        fi
        user=${args[1]}; z_err "user not specified" ${user};
        role=${args[2]};
        ssh -i /etc/ssh/gate/sys/agent.id -q devops@localhost \
            /home/devops/devops/ssh/jail.sh remo ${user} ${role}
        ;;
    box)
        hot=${HOSTS["${usr}"]}; z_err "host not specified" ${hot};
        docker=${args[1]};      z_err "dbox not specified" ${docker};
        if [[ "${docker}" == "status" ]]; then
            ssh -i /etc/ssh/gate/sys/agent.id devops@${hot} \
                docker ps -f "name=${usr}-" 2>/dev/null
        else
            if [[ "${docker}" == "devel" ]]; then
                docker="client"
            fi
            ssh -i /etc/ssh/gate/sys/agent.id -q devops@${hot} \
                /home/devops/docker/etc/azure.sh ${usr} ${docker}
        fi
        ;;
    sec)
        if [[ ! ${usr} =~ ^(chenp|tcyang|wujz|ydfeng|zhengjh|zslai)$ ]]; then
            z_err "forbidden"
        fi
        for hot in devel deve2 camp; do
            ssh -i /etc/ssh/gate/sys/agent.id devops@${hot} \
                "cd env-dev && git pull && sudo ./file.sh"
        done
        ssh -i /etc/ssh/gate/sys/agent.id devops@runner \
            "cd env-dev && git pull && ./docker.sh"
        ;;
    *)
        z_err "command not supported"
        ;;
esac
