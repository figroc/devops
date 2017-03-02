#!/bin/sh

if [ -z "$1" ]; then
    echo "./server.sh <server_root_domain_name>"
    exit 1
fi

SUBJ=server/$1
mkdir -p $SUBJ

if [ -f $SUBJ/server.crt ]; then
    openssl ca -config openssl.conf -revoke $SUBJ/server.crt
fi

openssl genrsa -out $SUBJ/server.key 2048 
openssl req -config openssl.conf -key $SUBJ/server.key \
    -new -sha256 -subj "/CN=*.$1" \
    -out $SUBJ/server.csr  
openssl ca -config openssl.conf -extensions server_cert \
    -days 375 -notext -md sha256 \
    -in $SUBJ/server.csr -out $SUBJ/server.crt

openssl verify -CAfile ca/ca.crt $SUBJ/server.crt
cat $SUBJ/server.crt ca/ca.crt > $SUBJ/server.crt.chain

