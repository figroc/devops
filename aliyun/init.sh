#!/bin/bash -e

sudo apt-get update
sudo apt-get install -y \
    jq
sudo pip install -U \
    aliyuncli \
    aliyun-python-sdk-core \
    aliyun-python-sdk-ecs \
    aliyun-python-sdk-alidns

aliyuncli configure set --region cn-hangzhou --output json
aliyuncli configure
