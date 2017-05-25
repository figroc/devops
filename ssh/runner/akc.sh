#!/bin/bash
#
# used for AuthorizedKeysCommand in sshd_config
#
# Usage: 
#   akc.sh user
#

gate='/etc/ssh/gate'

cat ${gate}/crews/${1}.pub 2>/dev/null
