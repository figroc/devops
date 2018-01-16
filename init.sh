#!/bin/bash -e
#
# setup common tools
#

source $(dirname ${0})/env

if [ "$(id -u)" -eq "0" ]; then
    useradd -m -U -s /bin/bash -c Ubuntu \
        -G sudo,dialout,dip,plugdev,netdev,cdrom,floppy,audio,video \
        ${devops}
    echo "devops ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-users
    cp -a ~/.ssh /home/${devops}/
    mv ~/${devops} /home/${devops}/
    chown -R ${devops}:${devops} /home/${devops}/.ssh /home/${devops}/${devops}
    shutdown -r now
fi

if [ ! -f /etc/sysctl.d/50-deepro.conf ]; then
    echo "vm.max_map_count = 262144" | sudo tee /etc/sysctl.d/50-deepro.conf
    sudo sysctl -w vm.max_map_count=262144
fi
if [ ! -f /etc/security/limits.d/50-deepro.conf ]; then
    (
      echo "root hard nofile  unlimited"
      echo "root soft nofile  unlimited"
      echo "*    hard nofile  unlimited"
      echo "*    soft nofile  unlimited"
      echo "root hard memlock unlimited"
      echo "root soft memlock unlimited"
      echo "*    hard memlock unlimited"
      echo "*    soft memlock unlimited"
    ) | sudo tee /etc/security/limits.d/50-deepro.conf
fi
if ! grep pam_limits.so /etc/pam.d/common-session; then
    echo "session required pam_limits.so" | sudo tee -a /etc/pam.d/common-session
fi

if ! grep deepro.io /etc/hosts; then
    echo "10.2.0.4  deepro.io" | sudo tee -a /etc/hosts
fi

if [ ! -d ~/${devops} ]; then
    git -C ~ clone ${repo}
fi

sudo apt-get update && \
sudo apt-get install -y gdisk tree plzip zip
