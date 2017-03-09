#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc-sys.sh user
#

gate='/etc/ssh/gate'

for role in sftp; do
    if [ ${role} == $1 ]; then
        cat ${gate}/sys/*.pub ${gate}/crews/*.pub
    fi
done
