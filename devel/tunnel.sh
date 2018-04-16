#!/bin/bash -e
#
# reverse tunnel setup
#

source $(dirname ${0})/../.env

if [[ -z "${1}" ]]; then
    echo "${0} <gateway> [port]" 1>&2
    exit 1
else
    svc_target="devops@${1}"
fi

if [[ -z "${2}" ]]; then
    svc_name="stunnel.service"
    svc_title="Secure Tunnel"
    svc_mappt="-R2222:localhost:22 -L0.0.0.0:443:deepro.io:443"
else
    svc_name="dp_${2}.service"
    svc_title="Secure Proxy ${2}"
    svc_mappt="-R0.0.0.0:${2}:localhost:${2}"
fi

cat >/etc/systemd/system/${svc_name} <<EOF
[Unit]
Description=${svc_title}
After=network.target

[Service]
Restart=always
RestartSec=37
User=root
ExecStart=/usr/bin/ssh -NT \\
    -i/home/devops/.ssh/id_rsa \\
    -oServerAliveInterval=60 \\
    -oExitOnForwardFailure=yes \\
    ${svc_mappt} ${svc_target}

[Install]
WantedBy=multi-user.target
EOF

if [[ "${svc_name}" == "" ]]; then
    svc_iptable="/etc/network/if-pre-up.d/stunnel"
    cat >${svc_iptable} <<-'EOF'
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
    chmod +x ${svc_iptable}
    ${svc_iptable}
fi

systemctl enable ${svc_name}
systemctl start  ${svc_name}
