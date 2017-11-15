#!/bin/bash -e
#
# setup common tools
#

source $(dirname ${0})/../env

if ! grep deepro.io /etc/hosts; then
    echo "10.2.0.4  deepro.io" | sudo tee -a /etc/hosts
fi

if [ ! -d ~/${devops} ]; then
    git clone ${repo}
fi

sudo apt-get update && apt-get -y install tree plzip zip
