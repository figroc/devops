#!/bin/bash -e

ecs=${1}

echo "10 * * * * devops /home/devops/devops/aliyun/ecs/cron/auto_scale.sh ${ecs}" > /etc/cron.d/auto_scale_vm
