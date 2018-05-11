#!/bin/bash -e
#
# reverse tunnel setup
#

source $(dirname ${0})/../.env

case "${2}" in
    ssh)
        svc_name="stunnel.service"
        svc_title="Secure SSH Tunnel"
        svc_mappt="-R${3:-2222}:localhost:22"
        ;;
    registry)
        svc_name="sregistry.service"
        svc_title="Secure Registry Proxy"
        svc_mappt="-L0.0.0.0:443:deepro.io:443"
        ;;
    port)
        if [[ -z "${3}"]]; then
            echo "not port specified" 1>&2
            exit 1
        fi
        svc_name="sreverse_${3}.service"
        svc_title="Secure Reverse ${3}"
        svc_mappt="-R0.0.0.0:${3}:localhost:${3}"
        ;;
    *)
        echo "${0} <gateway> <ssh|registry|port>" 1>&2
        exit 1
        ;;
esac

svc_target="${devops}@${1}"
if [[ ! -f /home/${devops}/.ssh/id_rsa.pub ]]; then
    ssh-keygen -t rsa -b 2048 -N '' -f /home/${devops}/.ssh/id_rsa
    ssh-copy-id -i /home/${devops}/.ssh/id_rsa.pub ${svc_target}
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
    -i/home/${devops}/.ssh/id_rsa \\
    -oServerAliveInterval=60 \\
    -oExitOnForwardFailure=yes \\
    ${svc_mappt} ${svc_target}

[Install]
WantedBy=multi-user.target
EOF

systemctl enable ${svc_name}
systemctl start  ${svc_name}
