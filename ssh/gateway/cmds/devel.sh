#!/bin/bash -e

function z_err() {
    if [[ -z ${2} ]]; then echo ${1} 1>&2; exit 1; fi
}

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1}; z_err "user not specified" ${usr};
hot=${2}; z_err "host not specified" ${hot};
pot=${3}; z_err "port not specified" ${pot};
cmd=${args[0]};

case ${cmd} in
    "") ;;
    jupyter)
        if [[ "${usr}" == "tcyang" ]]; then
            opt=" -L19182:127.0.0.1:8888"
        elif [[ "${usr}" == "zhangjie" ]]; then
            opt=" -L10062:127.0.0.1:8888"
        else
            soc="/tmp/${usr}.jupyter"
            opt=" -L${soc}:127.0.0.1:8888"
            rm -f ${soc}
        fi;;
    *)  exit 1;;
esac

ssh -q${opt} -p${pot} ${usr}@${hot}

if [[ ! -z ${soc} ]]; then rm -f ${soc}; fi