#!/bin/bash -e
#
# ip addr operation
#

source $(dirname ${0})/../env

ifc="/etc/network/interfaces.d/50-cloud-init.cfg"

act="${1}"
case ${act} in
    add)# e.g. 10.0.0.1/24
        if grep eth0:1 ${ifc}; then
            echo $'\n'"already exists" >&2
            exit 1
        fi
        ( echo
          echo "auto eth0:1"
          echo "iface eth0:1 inet static"
          echo "address ${2}"
          echo "netmask ${3}"
        ) >> ${ifc}
        ifup eth0:1
        ;;
    *)
        ;;
esac
