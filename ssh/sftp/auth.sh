#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   auth.sh user
#

gate='/etc/ssh/gate'

if [ $1 = 'sftp' ]; then
    cat ${gate}/sys/*.pub
fi
