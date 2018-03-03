#!/bin/bash
#
# install mysql python connector
#

function install_pkg {
  if [[ ! -f ${2} ]]; then
    wget -NP /tmp ${1}/${2}
  fi
  if [[ ! -f ${2} ]]; then
    echo 'download failed: '${2} >&2
  elif md5sum ${2} | grep ${3}; then
    dpkg -i /tmp/${2} && rm /tmp/${2}
  else
    echo 'checksum error: '${2} >&2
  fi
}

url='http://mirrors.kernel.org/ubuntu/pool/main/p/protobuf'
pkg='libprotobuf8_2.5.0-9ubuntu1_amd64.deb'
install_pkg ${url} ${pkg} e0ef0861f40071ed6f6606ac3b7c3742

url='https://dev.mysql.com/get/Downloads'
pkg='mysql-shell_1.0.8-rc-1ubuntu14.04_amd64.deb'
install_pkg ${url}/MySQL-Shell ${pkg} 1bfc6cf4dea865a619e274d6685d82ff

pkg='mysql-connector-python_2.1.5-1ubuntu14.04_all.deb'
install_pkg ${url}/Connector-Python ${pkg} 4f7b33388fbaf705182725039e37997f
