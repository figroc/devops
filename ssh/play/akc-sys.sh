#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc-sys.sh user
#

gate='/etc/ssh/gate'

case $1 in
    play)
        cat ${gate}/sys/*.pub
        ;;
    *)
        ;;
esac
