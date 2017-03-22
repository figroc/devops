#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc.sh user
#

gate='/etc/ssh/gate'
projs=('greennet' 'easyops')

case $1 in
    sftp)
        cat ${gate}/sys/*.pub ${gate}/crews/*.pub 2>/dev/null
        ;;
    *)
        for pi in ${projs[@]}; do
            if [[ ${projs[${pi}]} == $1 ]]; then
                cat ${gate}/projs/$1/*.pub 2>/dev/null
                break
            fi
        done
        ;;
esac
exit 0
