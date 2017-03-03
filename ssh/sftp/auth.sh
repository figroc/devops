#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   auth.sh user
#

if [ $1 = 'sftp' ]; then
    cat /var/gate/sys/*.pub
fi
