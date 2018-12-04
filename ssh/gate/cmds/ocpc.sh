#!/bin/bash -e

source $(dirname $0)/.env

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${1}
act=${args[0]}; z_err "user not specified" ${act};

rm -rf /tmp/${usr}.socks
ssh -t -i /etc/ssh/gate/sys/agent.id \
    -L/tmp/${usr}.socks:127.0.0.1:2080 \
    -q jumper@pts.n.cloudbrain.pro \
    ssh -p 2222 ${act}@localhost
rm -rf /tmp/${usr}.socks
