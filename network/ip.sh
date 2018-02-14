#!/bin/bash -e
#
# ip addr operation
#

source $(dirname ${0})/../env

act="${1}"
case ${act} in
    add)# e.g. 10.0.0.1/24
        ip address add "${2}" dev eth0
        (
          echo "auto eth0:1"
          echo "iface eth0:1 inet dhcp"
        ) >> /etc/network/interfaces.d/50-cloud-init.cfg
        ;;
    *)
        ;;
esac
