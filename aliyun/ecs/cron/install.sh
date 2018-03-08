#!/bin/bash -e

echo "10 * * * * devops /home/devops/devops/aliyun/ecs/cron/auto_scale.sh /home/devops/devops/ssh/gateway/cmds/env" > /etc/cron.d/auto_scale_vm
