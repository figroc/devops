#!/bin/bash

if [[ -z ${1} ]]; then
    echo "${0} <root>"
    exit 1
fi
root="${1}RootCA"

read -p "${root}: " CONFIRM
if [[ "$CONFIRM" != "NEW" ]]; then
    exit 1
fi

odir=${BASH_SOURCE%/*}
conf=${odir}/openssl.conf
card=${odir}/ca

mkdir -p ${card}/{db,crl,certs} 2> /dev/null
touch ${card}/db/{index.txt,index.txt.attr} 2> /dev/null
echo FACE > ${card}/db/serial
echo "00" > ${card}/crl/number

openssl genrsa -out ${card}/ca.key 8192
openssl req -config ${conf} -extensions v3_ca -key ${card}/ca.key \
    -new -x509 -days 7300 -sha256 -subj "/CN=${root}" \
    -out ${card}/ca.crt
openssl ca -config ${conf} -gencrl -out ${card}/crl/ca.crl -crldays 30
