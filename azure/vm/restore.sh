#!/bin/bash -e
#
# restore deallocated vm
#

gp=${1}
vm=${2}
sz=${3}
ab=${4}

if [[ -z "${sz}" ]]; then
  echo "${0} <resource-group> <vm-name> <vm-size> [availability-set]" >&2
  exit 1
fi

function az_res_list {
  local fmt="[?resourceGroup=='${1}' && starts_with(name, '${vm}')"
  if [[ -n "${3}" ]]; then
      local fmt="${fmt} && ${3}"
  fi
  local fmt="${fmt}].id"
  az ${2} list -o tsv --query="${fmt}" | tr -d "\n" | sed "s/ *$//"
}

echo "OS"
aod=$(az_res_list ${gp^^} "disk" "osType!=null")
echo "  Disk: ${aod}"
if [[ -z "${aod}" ]]; then
  exit 2
fi
ost=$(az disk show --ids ${aod} -o tsv --query="osType")
echo "  Type: ${ost}"

add=$(az_res_list ${gp^^} "disk" "osType==null")
if [[ -n "${add}" ]]; then
  echo "Data: ${add}"
  add="--attach-data-disks ${add}"
fi

nic=$(az_res_list ${gp} "network nic")
echo "NIC:  ${nic}"
if [[ -z "${nic}" ]]; then
  exit 2
fi
nic="--nics ${nic}"

echo
echo "creating..."
az vm create -g ${gp} -n ${vm} --verbose \
    --os-type ${ost} --size Standard_${sz} \
    ${ab:+--availability-set ${ab}} \
    --attach-os-disk ${aod} ${add} ${nic}
