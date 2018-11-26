#!/bin/bash -e

source $(dirname $0)/.env

read -a args <<< "${SSH_ORIGINAL_COMMAND}"

usr=${args[0]}; z_err "user not specified" ${usr};

ssh -t -i /etc/ssh/gate/sys/agent.id -q jumper@pts.n.cloudbrain.pro ssh -p 2222 ${usr}@localhost
