#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc.sh user
#

gate='/etc/ssh/gate'

case ${1} in
    play)
        cat ${gate}/sys/*.pub ${gate}/crews/*.pub 2>/dev/null
        ;;
esac
exit 0
