#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   auth.sh user
#

gate='/etc/ssh/gate'

case $1 in
    sftp)
        cat ${gate}/sys/*.pub
        ;;
    *)
        ;;
esac
