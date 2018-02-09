#!/bin/bash -e
#
# ip addr operation
#

source $(dirname ${0})/../env

act="${1}"
case ${act} in
    add)# e.g. 10.0.0.1/24
        ip addr add "${2}" dev eth0
        ;;
    *)
        ;;
esac
