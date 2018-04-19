#!/bin/bash -e
#
# ip addr operation
#

source $(dirname ${0})/../.env

function ipparse {
    ip_comp="${1}"
    ip_addr="${ip_comp%/*}"
    ip_size="${ip_comp#*/}"

    local m=0
    local i=${ip_size}
    while ((${i} > 0)); do
        local m=$((${m} * 2))
        local m=$((${m} + 1))
        local i=$((${i} - 1))
    done
    local i=$((32 - ${ip_size}))
    while ((${i} > 0)); do
        local m=$((${m} * 2))
        local i=$((${i} - 1))
    done

    ip_mask=""
    for i in {1..4}; do
        ip_mask="$((${m} & 255)).${ip_mask}"
        local m=$((${m} >> 8))
    done
    ip_mask="${ip_mask%.}"

    ip_inet=""
    for i in {1..4}; do
        local p=$(echo ${ip_addr} | cut -d. -f${i})
        local m=$(echo ${ip_mask} | cut -d. -f${i})
        ip_inet="${ip_inet}.$((${p} & ${m}))"
    done
    ip_inet="${ip_inet#.}"

    if ((${ip_size} >= 32)); then
        ip_gate="${ip_addr}"
    else
        ip_gate="${ip_inet%.*}.$((${ip_inet##*.} + 1))"
    fi
}

if [[ -z "${2}" ]]; then
    echo "${0} <action> <interface> [ip_address]" 1>&2
    exit 1
fi

act="${1}"
ifd="${2}"
case ${act} in
    add)
        ifc="/etc/network/interfaces.d/50-cloud-init.cfg"
        if grep ${ifd}:1 ${ifc}; then
            echo $'\n'"already exists" >&2
            exit 1
        fi
        if [[ -z "${3}" ]]; then
            echo "ip_address is required" >&2
            exit 1
        fi
        ipparse "${3}"
        ( echo
          echo "auto ${ifd}:1"
          echo "iface ${ifd}:1 inet static"
          echo "address ${ip_addr}"
          echo "netmask ${ip_mask}"
        ) >> ${ifc}
        ifup ${ifd}:1
        ;;
    sol)
        ifc="/etc/network/if-up.d/50-isolate-nic.sh"
        cat >${ifc} <<-EOF
		#!/bin/bash -e
		function main {
		  local ifd="\${1}"
		  local ift=\${ifd}
		  if ! grep \${ift} /etc/iproute2/rt_tables &>/dev/null; then
		    echo "5"$'\\t'"\${ift}" >> /etc/iproute2/rt_tables
		  fi
		  local ip4=\$(ip addr show dev \${ifd} | grep -Eo "([[:digit:]]{1,3}[./]){4}[[:digit:]]{1,2}" | cut -d/ -f1)
		  local ip3=\${ip4%.*}
		  ip route add      default      via \${ip3}.1 dev \${ifd}             table \${ift}
		  ip route add      \${ip3}.0/24               dev \${ifd} src \${ip4} table \${ift}
		  ip rule  add from \${ip4}/32                                         table \${ift}
		  ip rule  add to   \${ip4}/32                                         table \${ift}
		}
		if [[ "\${IFACE}" == "${ifd}" ]]; then
		  main "${ifd}"
		fi
		EOF
        chmod +x ${ifc}
        IFACE=${ifd} ${ifc}
        ;;
    *)
        echo "unkown command: ${act}" 1>&2
        exit 1
        ;;
esac
