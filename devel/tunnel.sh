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

iptable="/etc/network/if-pre-up.d/stunnel"
cat >${iptable} <<'EOF'
#!/bin/bash
function iptable_rule_set {
  iptables -C ${1} &>/dev/null || iptables -A ${1}
}
iptable_rule_set "INPUT -j ACCEPT -i lo"
iptable_rule_set "INPUT -j ACCEPT -i docker0"
iptable_rule_set "INPUT -j ACCEPT -p tcp --dport ssh"
iptable_rule_set "INPUT -j ACCEPT -m state --state ESTABLISHED,RELATED"
iptable_rule_set "INPUT -j REJECT"
EOF
chmod +x ${iptable}
${iptable}

systemctl enable stunnel.service
systemctl start  stunnel.service
