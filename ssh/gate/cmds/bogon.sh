#!/bin/bash -e

source $(dirname $0)/.env

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1};               z_err "user not specified" ${usr};
hot=${HOSTS["${usr}"]}; z_err "host not specified" ${hot};
pot=${PORTS["${usr}"]}; z_err "port not specified" ${pot};
cmd=${args[0]};

case ${cmd} in
    "")
        ssh -p${pot} -q ${usr}@localhost
        ;;
    box)
        dok=${args[1]:-status}; z_err "dbox not specified" ${dok};
        case "${dok}" in
            status)
                ssh -i /etc/ssh/gate/sys/agent.id -q devops@${hot} \
                    docker ps -f "name=${usr}-"
                ;;
            *)
                ssh -i /etc/ssh/gate/sys/agent.id -q devops@${hot} \
                    docker/etc/azure.sh ${usr} ${dok}
                ;;
        esac
        ;;
    *)
        z_err "${cmd} not supported"
        ;;
esac
