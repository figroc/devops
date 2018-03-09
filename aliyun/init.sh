#!/bin/bash -e
sudo apt-get update && sudo apt-get install -y jq
sudo pip install aliyuncli aliyun-python-sdk-core aliyun-python-sdk-ecs

aliyuncli configure set --region cn-hangzhou --output json
aliyuncli configure
