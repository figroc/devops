#!/bin/bash -e

domain="${1}"
subnme="${2}"
chalng="${3}"

rid=$(aliyuncli domain AddDomainRecord \
    --DomainName "${domain}" \
    --RR "_acme-challenge.${subnme}" \
    --Type TXT \
    --Value "${chalng}" \
    | jq '.RecordId' \
    | tr -d '"')
sleep 25
aliyuncli domain DeleteSubDomainRecords \
    --RecordId "${rid}"
