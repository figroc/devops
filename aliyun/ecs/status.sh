#!/bin/bash -e

ecs=${1}

aliyuncli ecs DescribeInstances \
    --InstanceIds "[\"${ecs}\"]" \
    | jq '.Instances.Instance[0].Status' \
    | tr -d '"'
