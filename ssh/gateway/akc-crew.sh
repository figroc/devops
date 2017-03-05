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

opt=${gate}'/servs/'${role}'.opt'
if [ -f ${opt} ]; then
    grep -e '^*:' -e '^'${user}':' ${opt} | tail -n 1 \
        | sed '/^.*:[[:blank:]]*/s///' | tr '\n' ' '
fi

key=${gate}'/crews/'${user}'.pub'
if [ -f ${key} ]; then
    cat ${key}
fi
