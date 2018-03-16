#!/bin/bash -e

source $(dirname $0)/env

function s_rm() {
    if [[ -f ${1} ]]; then sudo rm -f ${1}; fi
}

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1};       z_err "user not specified" ${usr};
cmd=${args[0]}; z_err "no command specified" ${cmd};

case "${cmd}" in
    ?)
        echo "box [status]: list running devel docker"
        echo "    <devel>:  reload devel docker"
        echo
        echo "vms [status]: list elastic vm pool status"
        echo "    start:    start one vm in pool"
        echo "    stop:     stop one vm in pool"
        echo
        echo "ban <user>:   block login"
        ;;
    ban)
        if [[ ! ${usr} =~ ^(chenp|byzhang|yaxin)$ ]]; then
            z_err "forbidden"
        fi
        user=${args[1]}; z_err "user not specified" ${user};
        role=${args[2]};
        ssh -i /etc/ssh/gate/sys/agent.id -q devops@localhost \
            devops/ssh/jail.sh remo ${user} ${role}
        ;;
    box)
        hot=${HOSTS["${usr}"]};    z_err "host not specified" ${hot};
        docker=${args[1]:+status}; z_err "dbox not specified" ${docker};
        case "${docker}" in
            status)
                ssh -i /etc/ssh/gate/sys/agent.id -q devops@${hot} \
                    docker ps -f "name=${usr}-"
                ;;
            *)
                ssh -i /etc/ssh/gate/sys/agent.id -q devops@${hot} \
                    docker/etc/azure.sh ${usr} ${docker}
        esac
        ;;
    vms)
        hot=${HOSTS["${usr}"]}; z_err "host not specified"   ${hot};
        act=${args[1]:+status}; z_err "action not specified" ${act};
        if [[ " status start stop " != *" ${act} "* ]]; then
            z_err "action not supported"
        fi
        for ecs in ${SPOOL[@]}; do
            echo -n "${ecs}: "
            ssh -i /etc/ssh/gate/sys/agent.id -q devops@localhost \
                devops/aliyun/ecs/${act}.sh ${ecs}
        done
        ;;
    sec)
        if [[ ! ${usr} =~ ^(chenp|tcyang|wujz|ydfeng|zhengjh|zslai)$ ]]; then
            z_err "forbidden"
        fi
        for hot in devel deve2 camp; do
            ssh -i /etc/ssh/gate/sys/agent.id -q devops@${hot} \
                "cd env-dev && git pull && sudo ./file.sh"
        done
        ssh -i /etc/ssh/gate/sys/agent.id -q devops@runner \
            "cd env-dev && git pull && ./docker.sh"
        ;;
    *)
        z_err "command not supported"
        ;;
esac
