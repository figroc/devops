#!/bin/bash -e
#
# reverse tunnel setup
#

source $(dirname ${0})/../.env

if [[ -z "${1}" ]]; then
    echo "${0} <ext-eth-if>" 1>&2
    exit 1
fi
DANTE_IF="${1}"

apt-get install -y gcc libwrap0 libwrap0-dev make

DANTE_VERSION="dante-1.4.2"
wget https://www.inet.no/dante/files/${DANTE_VERSION}.tar.gz
tar -xvf ${DANTE_VERSION}.tar.gz && cd ${DANTE_VERSION}

./configure --prefix=/usr/local
make
make install

cd .. && rm -rf ${DANTE_VERSION}.tar.gz ${DANTE_VERSION}

adduser --system --disabled-login --no-create-home dante || true

cat >/etc/danted.conf <<EOF
logoutput: /var/log/danted.log
internal: 127.0.0.1 port = 1080
external: ${DANTE_IF}
user.notprivileged: dante
clientmethod: none
socksmethod: none
client pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: error # connect disconnect
}
socks pass {
  from: 0.0.0.0/0 to: 0.0.0.0/0
  log: error # connect disconnect iooperation
}
EOF

cat >/etc/systemd/system/danted.service <<EOF
[Unit]
Description=Socks Proxy
After=network.target

[Service]
Restart=always
RestartSec=37
User=root
ExecStart=/usr/local/sbin/sockd -f /etc/danted.conf

[Install]
WantedBy=multi-user.target
EOF

systemctl enable danted.service
systemctl start  danted.service
