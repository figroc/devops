if [[ ! -f "$1" ]]; then
    echo "$1 is not a file or does not exist"
    exit 1
fi

openssl x509 -in "$1" -noout 2>/dev/null
if [[ $? -gt 0 ]]; then
    echo "$1 is not a certificate"
    exit 1
fi

mkdir .temp_cert_dir
awk '{print > (".temp_cert_dir/cert" (1+n) ".pem")} /-----END CERTIFICATE-----/ {n++}' "$1"

j=0
for i in .temp_cert_dir/cert*.pem ; do
    echo -n "$j: "
    openssl x509 -in "$i" -noout -subject -issuer
    j=$[$j+1]
done

rm -R .temp_cert_dir
