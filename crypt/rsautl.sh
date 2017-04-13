#! /bin/bash

use=$0' <-encrypt|-decrypt> <key> <file>'
if [[ $# -ne 3 ]]; then
    echo ${use} &>2
    exit 1
fi

key=$2
fnm=$3
case $1 in
    -encrypt)
        openssl rand 192 -out secret.key                    &&\
        openssl aes-256-cbc -in ${fnm} -out ${fnm}.enc \
            -pass file:secret.key                           &&\
        openssl rsautl -encrypt -pubin -inkey \
            <(ssh-keygen -e -f ${key} -m PKCS8) \
            -in secret.key -out secret.key.enc              &&\
        tar -cf ${fnm}.enc.tar ${fnm}.enc secret.key.enc    &&\
        rm secret.key secret.key.enc ${fnm}.enc
        ;;
    -decrypt)
        tar -xf ${fnm} && fnm=${fnm%.tar}                   &&\
        openssl rsautl -decrypt -ssl -inkey ${key} \
            -in secret.key.enc -out secret.key              &&\
        openssl aes-256-cbc -d -in ${fnm} -out ${fnm%.enc} \
            -pass file:secret.key                           &&\
        rm secret.key secret.key.enc ${fnm}
        ;;
    *)
        echo ${use} &> 2
        exit 1
        ;;
esac
exit $?
