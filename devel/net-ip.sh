#!/bin/bash -e
#
# ip addr operation
#

source $(dirname ${0})/../.env

function cidr {
    ip_cidr=$(echo "${1}" | grep -Eo '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}/[[:digit:]]{1,2}')
    if [[ -z "${ip_cidr}" ]]; then
        echo "invalid CIDR address: ${1}" 1>&2
        exit 1
    fi

    ip_addr=${ip_cidr%/*}
    ip_pref=${ip_cidr#*/}
    ip_size=$((32 - ${ip_pref}))

    ip_mask=""
    local m=$((  -1 >> ${ip_size}))
    local m=$((${m} << ${ip_size}))
    for i in {1..4}; do
        ip_mask="$((${m} & 255)).${ip_mask}"
        local m=$((${m} >> 8))
    done
    ip_mask="${ip_mask%.}"

    ip_inet=""
    for i in {1..4}; do
        local a=$(echo ${ip_addr} | cut -d. -f${i})
        local m=$(echo ${ip_mask} | cut -d. -f${i})
        ip_inet="${ip_inet}.$((${a} & ${m}))"
    done
    ip_inet="${ip_inet#.}"

    if ((${ip_pref} >= 32)); then
        ip_gate="${ip_addr}"
    else
        ip_gate="${ip_inet%.*}.$((${ip_inet##*.} + 1))"
    fi
}

function isol {
  local ifd="${1}"
  local ift="${1}"
  if ! grep ${ift} /etc/iproute2/rt_tables &>/dev/null; then
    echo "5"$'\t'"${ift}" >> /etc/iproute2/rt_tables
  fi

  cidr $(ip -4 addr show ${ifd} | grep 'inet')
  ip route add default via ${ip_gate} dev ${ifd}                table ${ift}
  ip route add ${ip_inet}/${ip_pref}  dev ${ifd} src ${ip_addr} table ${ift}

  local irs=($(ip rule | grep ${ift} | grep -Eo '^[[:digit:]]+'))
  for irn in ${irs[@]}; do ip rule del pref ${irn}; done
  ip rule  add from ${ip_addr}/32 table ${ift}
  ip rule  add to   ${ip_addr}/32 table ${ift}
}

if [[ -z "${2}" ]]; then
    echo "${0} <action> <interface> [cidr]" 1>&2
    exit 1
fi

act="${1}"
ifd="${2}"
case ${act} in
    add)
        ifc="/etc/network/interfaces.d/50-cloud-init.cfg"
        ifd="${ifd}:1"
        if [[ -z "${3}" ]]; then
            echo "cidr is required" >&2
            exit 1
        fi
        cidr "${3}"
        cat >${ifc} <<-EOF
			auto  ${ifd}
			iface ${ifd} inet static
			address ${ip_addr}
			netmask ${ip_mask}
			EOF
        ifup ${ifd}
        ;;
    sol)
        ifc="/etc/network/if-up.d/50-isolate-nic.sh"
        cat >${ifc} <<-EOF
			#!/bin/bash -e
			$(type cidr | tail -n+2)
			$(type isol | tail -n+2)
			if [[ "\${IFACE}" == "${ifd}" ]]; then
			  isol "${ifd}"
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
