
测试手机证书安装方法
--------------------
### [ android ]
测试手机使用测试环境时需要安装测试环境的CA根证书，通过adb命令进行安装：

    CA="test.ca.crt"
    RN="$(openssl x509 -inform PEM -subject_hash_old -noout -in ${CA}).0"
    cp ${CA} ${RN} && adb push ${RN} /system/etc/security/cacerts && rm ${RN}

或者直接信任特定站点的SSL证书，获取方法：

    openssl s_client -showcerts -connect ${HOST}:${PORT} </dev/null 2>/dev/null |\
    openssl x509 -outform PEM >${CERT_FILE}

测试服务器证书安装方法
----------------------
根据服务所使用的域名进行选择对应域名下的 server.crt.chain 和 server.key，以 google.com 的
二级子域名为例
### [ nginx ]

    ssl_certificate     server/google.com/server.crt.chain
    ssl_certificate_key server/google.com/server.key

### [ apache ]

    SSLCertificateFile      server/google.com/server.crt
    SSLCertificateKeyFile   server/google.com/server.key
    SSLCertificateChainFile ca/ca.crt

### [ nodejs]

https://nodejs.org/api/https.html
