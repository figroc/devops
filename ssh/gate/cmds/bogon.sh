#!/bin/bash -e

source $(dirname $0)/.env

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1}; z_err "user not specified" ${usr};
if [[ "${args[0]}" == "fwd" ]]; then
    fwn=$(echo "${args[1]}" | tr -cd '[:alpha:]')
    fwp=$(echo "${args[2]}" | tr -cd '[:digit:]')
    if [[ -n "${fwn}" ]] && [[ -n "${fwp}" ]]; then
        soc="/tmp/${user}.${fwn}"
        opt="-L${soc}:${soc}"
        rm -f ${soc}
    fi
fi
ssh ${opt} -p2222 -q ${usr}.devel@localhost "${SSH_ORIGINAL_COMMAND}"
test -n "${soc}" && rm -f ${soc}
