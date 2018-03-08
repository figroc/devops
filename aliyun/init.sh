#!/bin/bash -e
apt-get install -y jq
pip install aliyuncli aliyun-python-sdk-core
aliyuncli configure set --region cn-hangzhou --output json
aliyuncli configure
