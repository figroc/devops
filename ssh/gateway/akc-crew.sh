#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc-crew.sh user
#

gate='/etc/ssh/gate'

IFS=. read user role <<EOF
$1
EOF

cmd=$(grep ${gate}/roles/${role}.opt \
    -e '^[[:blank:]]*[*][[:blank:]]*:[[:blank:]]*' \
    -e '^[[:blank:]]*'${user}'[[:blank:]]*:[[:blank:]]*' \
    | tail -n 1 | sed '/^.*:[[:blank:]]*/s///' | tr -d '\n')

while read line; do
    echo ${cmd} ${line}
done < ${gate}/crews/${user}.pub
