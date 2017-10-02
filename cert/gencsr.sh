#! /bin/bash

if [[ $# -ne 1 ]]; then
    echo $0' <domain>' >&2
    exit 1
fi

dots=$(echo $1 | tr -cd '.' | wc -c)
if [[ ${dots} -eq 0 ]]; then
    echo 'gLTD not allowed' >&2
    exit 1
fi

opts=(\
    ''\
    '/C=US/ST=California/L=Mountain View/O=CloudBrain Inc.'\
    '/C=CN/ST=Yunnan/L=Dali/O=AiXinZhuXue Org.'\
    )
optn=${#opts[@]}
echo 'select or input subject field: '
echo '  0) <EMPTY>'
for (( i=1; i<${optn}; i++)); do
    echo '  '${i}') '${opts[${i}]}
done
printf '[0]? '

read opt
if [[ ${opt} =~ ^[0-9]+$ ]]; then
    if [[ ${opt} -lt ${optn} ]]; then
        subj=${opts[${opt}]}
    else
        echo 'invalid selection' >&2
        exit 1
    fi
else
    case ${opt} in
        q) exit 0;;
        *) subj=${opt};;
    esac
fi

subj=${subj}'/CN='
altn=$'[SAN]\nsubjectAltName=DNS:'$1

if [[ ${dots} -eq 1 ]]; then
    subj=${subj}'*.'$1
    altn=${altn}',DNS:*.'$1
else
    subj=${subj}$1
    if [[ $1 == www.* ]]; then
        altn=${altn}',DNS:'${1:4}
    fi
fi

if [[ ! -f $1.key ]]; then
    openssl genrsa 4096 > $1.key
fi
openssl req -new -sha256 -key $1.key -out $1.csr \
    -subj "${subj}" -reqexts SAN -config \
    <(cat /etc/ssl/openssl.cnf <(printf "${altn}"))
