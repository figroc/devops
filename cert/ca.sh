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

mkdir -p ${ca_d}/{db,crl,certs}
#touch ${ca_d}/db/{serial,index.txt,index.txt.attr}
#touch ${ca_d}/crl/number

openssl genrsa -out ${ca_f}.key 8192
openssl req -config ${conf} -extensions v3_ca -key ${ca_f}.key \
    -new -x509 -days 7300 -sha256 -subj "/CN=${root}" \
    -out ${ca_f}.crt
openssl ca -config ${conf} -gencrl -out ${ca_f}.crl -crldays 30
