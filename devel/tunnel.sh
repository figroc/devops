#!/bin/bash -e
#
# reverse tunnel setup
#

source $(dirname ${0})/../.env

cat >/etc/systemd/system/stunnel.service <<EOF
[Unit]
Description=Secure Tunnel
After=network.target

[Service]
RestartSec=5
Restart=always
User=devops
Environment="TARGET=w.cloudbrain.pro"
ExecStart=/usr/bin/ssh -NT -oServerAliveInterval=60 -oExitOnForwardFailure=yes -R2222:localhost:22 ${TARGET}

[Install]
WantedBy=multi-user.target
EOF

systemctl enable stunnel.service
systemctl start  stunnel.service
