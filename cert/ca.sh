#!/bin/sh
echo "TestEnvRootCA: "
read CONFIRM
if ("$CONFIRM" != "NEW"); then
    exit 1
fi

mkdir -p ca/certs
mkdir -p ca/crl
mkdir -p ca/db
touch ca/db/index.txt
touch ca/db/index.txt.attr
echo FACE > ca/db/serial
echo "00" > ca/crl/number

openssl genrsa -out ca/ca.key 4096
openssl req -config openssl.conf -extensions v3_ca -key ca/ca.key \
    -new -x509 -days 7300 -sha256 -subj "/CN=TestEnvRootCA" \
    -out ca/ca.crt  
openssl ca -config openssl.conf -gencrl -out ca/crl/ca.crl -crldays 30 
