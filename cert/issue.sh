#!/bin/bash

odir=${BASH_SOURCE%/*}
conf=${odir}/openssl.conf
ca_f=${odir}/ca/ca.crt

function issue {
    subj_n=$3
    subj_d=${odir}/$1/$2
    subj_f=${subj_d}/$1

    case $1 in
        server)
            ext_n='server_cert'
            ;;
        user)
            ext_n='usr_cert'
            ;;
    esac

    mkdir -p ${subj_d}

    if [ -f ${subj_f}.crt ]; then
        openssl ca -config ${conf} -revoke ${subj_f}.crt
    fi

    openssl genrsa -out ${subj_f}.key 4096 
    openssl req -config ${conf} -key ${subj_f}.key \
        -new -sha256 -subj "/CN=${subj_n}" \
        -out ${subj_f}.csr  
    openssl ca -config ${conf} -extensions ${ext_n} \
        -days 375 -notext -md sha256 \
        -in ${subj_f}.csr -out ${subj_f}.crt

    openssl verify -CAfile ${ca_f} ${subj_f}.crt
    cat ${subj_f}.crt ${ca_f}.crt > ${subj_f}.crt.chain
}

function usage {
    echo "issue.sh server <root-domain>\nissue.sh user <name>"
}

if (( $# < 2 )); then
    usage
    exit 1
fi

case $1 in
    server)
        issue server $2 *.$2
        ;;
    user)
        issue user $2 $2
        ;;
    *)
        usage
        exit 1
        ;;
esac
