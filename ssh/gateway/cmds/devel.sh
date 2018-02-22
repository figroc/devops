#!/bin/bash -e

source $(dirname $0)/env

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1};             z_err "user not specified" ${usr};
hot=${HOSTS[${usr}]}; z_err "host not specified" ${hot};
pot=${PORTS[${usr}]}; z_err "port not specified" ${pot};
cmd=${args[0]};

case ${cmd} in
    "") ;;
    jupyter)
        if [[ "${usr}" == "tcyang" ]]; then
            opt="-L19182:127.0.0.1:8888"
        elif [[ "${usr}" == "zhangjie" ]]; then
            opt="-L10062:127.0.0.1:8888"
        else
            soc="/tmp/${usr}.jupyter"
            opt="-L${soc}:127.0.0.1:8888"
            rm -f ${soc}
        fi;;
    *)  exit 1;;
esac

ssh ${opt} -p${pot} -q ${usr}@${hot}

if [[ ! -z ${soc} ]]; then rm -f ${soc}; fi
