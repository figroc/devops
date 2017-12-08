#!/bin/bash -e
#
# setup common tools
#

source $(dirname ${0})/../env

if [ "$(id -u)" -eq "0" ]; then
    useradd -m -U -s /bin/bash -c Ubuntu ${devops}
    usermod -a ${devops} -G sudo,dialout,dip,plugdev,netdev,cdrom,floppy,audio,video
    echo "devops ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
    mkdir -p /home/${devops}/.ssh
    cp .ssh/authorized_keys /home/${devops}/.ssh/
    chown -R ${devops}:${devops} /home/${devops}/.ssh
    chmod -R go-rwx /home/${devops}/.ssh
    shutdown -r now
fi

if [ ! -f /etc/sysctl.d/60-elastic.conf ]; then
    echo "vm.max_map_count=262144" | sudo tee /etc/sysctl.d/60-elastic.conf
    sudo sysctl -w vm.max_map_count=262144
fi

if ! grep deepro.io /etc/hosts; then
    echo "10.2.0.4  deepro.io" | sudo tee -a /etc/hosts
fi

if [ ! -d ~/${devops} ]; then
    git -C ~ clone ${repo}
fi

sudo apt-get update &&\
sudo apt-get -y install tree plzip zip
