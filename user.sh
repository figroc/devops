#!/bin/sh

if [ -z "$1" ]; then
    echo "./user.sh <user_identity>"
    exit 1
fi

SUBJ=user/$1
mkdir -p $SUBJ

if [ -f $SUBJ/client.crt ]; then
    openssl ca -config openssl.conf -revoke $SUBJ/client.crt
fi

openssl genrsa -out $SUBJ/client.key 2048 
openssl req -config openssl.conf -key $SUBJ/client.key \
    -new -sha256 -subj "/CN=$1" \
    -out $SUBJ/client.csr  
openssl ca -config openssl.conf -extensions usr_cert \
    -days 375 -notext -md sha256 \
    -in $SUBJ/client.csr -out $SUBJ/client.crt

openssl verify -CAfile ca/ca.crt $SUBJ/client.crt

