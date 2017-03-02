#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   auth.sh user
#

IFS=. read user serv <<EOF
$1
EOF

user='/root/crews/'${user}'.pub'
serv='/root/servs/'${serv}'.opt'

if [[ -f ${user} && -f ${serv} ]]; then
    cat ${serv} ${user} | xargs
fi
