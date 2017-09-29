#!/bin/bash

function usage {
    echo "$0 svr <domain> [subject]"
    echo "$0 usr <name> [subject]"
    exit 1
}

if (( $# < 2 )); then
    usage
fi

odir=${BASH_SOURCE%/*}
conf=${odir}/openssl.conf
ca_f=${odir}/ca/ca.crt

function genr {
    subj_d=${odir}/${role}/${name}
    subj_f=${subj_d}/${role}

    mkdir -p ${subj_d}
    if [ -f ${name}.csr ]; then
        mv ${name}.csr ${subj_d}/
    else
        openssl genrsa -out ${subj_f}.key 4096
        openssl req -config ${conf} -key ${subj_f}.key \
            -new -sha256 -subj "/CN=${subj_n}" \
            -out ${subj_f}.csr
    fi
}

function sign {
    if [ -f ${subj_f}.crt ]; then
        openssl ca -config ${conf} -revoke ${subj_f}.crt
    fi
    openssl ca -config ${conf} -extensions ${ext_n} \
        -days 375 -notext -md sha256 \
        -in ${subj_f}.csr -out ${subj_f}.crt
    openssl verify -CAfile ${ca_f} ${subj_f}.crt
    cat ${subj_f}.crt ${ca_f} > ${subj_f}.crt.chain
}

role=$1
name=$2
subj_n=$3
case ${role} in
    svr)
        ext_n='server_cert'
        if [[ -z ${subj_n} ]]; then
            subj_n="*.${name}"
        fi
        ;;
    usr)
        ext_n='usr_cert'
        if [[ -z ${subj_n} ]]; then
            subj_n=${name}
        fi
        ;;
    *)
        usage
        ;;
esac

genr
sign
