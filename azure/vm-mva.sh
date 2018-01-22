#!/bin/bash -e
#
# mv vm to availability set
#

gp=${1}
vm=${2}
ab=${3}

if [[ -z "${ab}" ]]; then
  echo "${0} <resource-group> <vm-name> <availability-set>" >&2
  exit 1
fi

function az_vm_show {
  az vm show -g ${gp} -n ${vm} -o tsv --query "${1}" | tr "\n" " " | sed "s/ *$//"
}

avl=$(az_vm_show "availabilitySet.id")
echo "Availability Set: ${avl}"
if echo "${avl}" | grep -qi "${ab}"; then
  exit 2
fi

vms=$(az_vm_show "hardwareProfile.vmSize" | sed "s/_v2$//")
echo "Size:  ${vms}"

flg=""

aod=$(az_vm_show "storageProfile.osDisk.managedDisk.id")
if [[ -z "${aod}" ]]; then
  aod=$(az_vm_show "storageProfile.osDisk.vhd.uri")
  flg="--use-unmanaged-disk"
fi
echo "OS D:  ${aod}"

nic=$(az_vm_show "networkProfile.networkInterfaces[].id")
echo "NIC:   ${nic}"
if [[ -n "${nic}" ]]; then
  nic="--nics ${nic}"
fi

add=$(az_vm_show "storageProfile.dataDisks[].managedDisk.id")
if [[ -z "${add}" ]]; then
  add=$(az_vm_show "storageProfile.dataDisks[].vhd.uri")
fi
echo "Data:  ${add}"
if [[ -n "${add}" ]]; then
  add="--attach-data-disks ${add}"
fi

echo
echo "deleting..."
az vm delete -g ${gp} -n ${vm} --verbose --yes
echo
echo "recreating..."
az vm create -g ${gp} -n ${vm} --verbose \
    --os-type linux --size ${vms} \
    --availability-set ${ab} ${flg} \
    --attach-os-disk ${aod} ${add} ${nic}
