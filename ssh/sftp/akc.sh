#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc.sh user
#

gate='/etc/ssh/gate'

if [[ ${1} == sftp ]]; then
    cat ${gate}/sys/*.pub ${gate}/crews/*.pub 2>/dev/null
else
    cat ${gate}/projs/${1}/*.pub 2>/dev/null
fi
exit 0
