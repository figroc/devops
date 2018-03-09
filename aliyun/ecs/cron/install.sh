#!/bin/bash -e
(
    echo "PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin"
    echo "*/5 * * * * devops cd ~/devops && aliyun/ecs/cron/auto_scale.sh ssh/gateway/cmds/env"
) > /etc/cron.d/auto_scale_vm
