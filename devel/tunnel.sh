#!/bin/bash -e
#
# reverse tunnel setup
#

source $(dirname ${0})/../.env

cat >/etc/systemd/system/stunnel.service <<'EOF'
[Unit]
Description=Secure Tunnel
After=network.target

[Service]
Restart=always
RestartSec=37
User=root
ExecStart=/usr/bin/ssh -NT \
    -i/home/devops/.ssh/id_rsa \
    -oServerAliveInterval=60 \
    -oExitOnForwardFailure=yes \
    -R2222:localhost:22 \
    -L0.0.0.0:443:deepro.io:443 \
    devops@w.cloudbrain.pro

[Install]
WantedBy=multi-user.target
EOF

iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i docker0 -j ACCEPT
iptables -A INPUT -j REJECT

systemctl enable stunnel.service
systemctl start  stunnel.service
