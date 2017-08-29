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
ca_d=${odir}/ca
ca_f=${ca_d}/ca
ca_r=${ca_d}/crl/ca.crl

mkdir -p ${ca_d}/{db,crl,certs} 2> /dev/null
touch ${ca_d}/db/{index.txt,index.txt.attr} 2> /dev/null
echo FACE > ${ca_d}/db/serial
echo "00" > ${ca_d}/crl/number

openssl genrsa -out ${ca_f}.key 8192
openssl req -config ${conf} -extensions v3_ca -key ${ca_f}.key \
    -new -x509 -days 7300 -sha256 -subj "/CN=${root}" \
    -out ${ca_f}.crt
openssl ca -config ${conf} -gencrl -out ${ca_r} -crldays 30
