#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc.sh user
#

gate='/etc/ssh/gate'
projs="greenet s360 wind sse gionee editor"

IFS=. read user role <<EOF
${1}
EOF

if id -nG ${user}.${role} | grep -qw crews; then
    pub=${gate}/crews/${user}.pub
    opt=${gate}/roles/${role}.opt
elif echo ${projs} | grep -qw ${role}; then
    pub=${gate}/projs/${role}/${user}.pub
    opt=${gate}/roles/none.opt
else
    exit 1
fi

cmd=$(grep ${opt} \
    -e '^[[:blank:]]*[*][[:blank:]]*:[[:blank:]]*' \
    -e '^[[:blank:]]*'${user}'[[:blank:]]*:[[:blank:]]*' \
    | tail -n 1 | sed '/^[^:]*:[[:blank:]]*/s///' | tr -d '\n')

while read line; do
    echo ${cmd} ${line}
done < ${pub}
