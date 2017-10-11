#!/bin/bash -e

function z_err() {
    if [[ -z ${2} ]]; then echo ${1} 1>&2; exit 1; fi
}

function s_rm() {
    if [[ -f ${1} ]]; then sudo rm ${1}; fi
}

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1}; z_err "user not specified" ${usr};
hot=${2}; z_err "host not specified" ${hot};
pot=${3}; z_err "port not specified" ${pot};
cmd=${args[0]};

case ${cmd} in
    jupyter)
        s_rm /tmp/${usr}.jupyter
        opt=" -L/tmp/${usr}.jupyter:127.0.0.1:8888 -oExitOnForwardFailure=yes"
        ;;
    *)
        ;;
esac

ssh -q${opt} -p${pot} ${usr}@${hot}
