#! /bin/bash -e

use=$0' <-encrypt|-decrypt> <key> <file>'
if [[ $# -ne 3 ]]; then
    echo ${use} &>2
    exit 1
fi

key=$2
fnm=$3
case $1 in
    -encrypt)
        openssl rand 192 -out .secret.key
        openssl aes-256-cbc -e -pass file:.secret.key \
            -in ${fnm} -out ${fnm}.enc
        openssl rsautl -encrypt -pubin -inkey \
            <(ssh-keygen -e -f ${key} -m PKCS8) \
            -in .secret.key -out .secret.enc
        tar -cf ${fnm}.crypt ${fnm}.enc .secret.enc
        rm .secret.key .secret.enc ${fnm}.enc
        ;;
    -decrypt)
        tar -xf ${fnm} && fnm=${fnm%.crypt}
        openssl rsautl -decrypt -ssl -inkey ${key} \
            -in .secret.enc -out .secret.key
        openssl aes-256-cbc -d -pass file:.secret.key \
            -in ${fnm}.enc -out ${fnm}
        rm .secret.key .secret.enc ${fnm}.enc
        ;;
    *)
        echo ${use} &> 2
        exit 1
        ;;
esac
