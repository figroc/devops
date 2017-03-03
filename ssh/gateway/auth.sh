#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   auth.sh user
#

gate='/etc/ssh/gate'

IFS=. read user role <<EOF
$1
EOF

key=${gate}'/crews/'${user}'.pub'
opt=${gate}'/servs/'${role}'.opt'

if [[ -f ${key} && -f ${opt} ]]; then
    cat ${opt} ${key} | tr '\n' ' ' | sed 's/[[:space:]]*$/\n/'
fi
