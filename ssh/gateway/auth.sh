#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   auth.sh user
#

gate='/etc/ssh/gate'

IFS=. read user serv <<EOF
$1
EOF

user=${gate}'/crews/'${user}'.pub'
serv=${gate}'/servs/'${serv}'.opt'

if [[ -f ${user} && -f ${serv} ]]; then
    cat ${serv} ${user} | tr '\n' ' ' | sed 's/[[:space:]]*$/\n/'
fi
