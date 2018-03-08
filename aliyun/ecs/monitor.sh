#!/bin/bash -e

ecs=${1}

load=( $(aliyuncli ecs DescribeInstanceMonitorData \
    --StartTime $(date -u +%FT%TZ -d "-30 minutes") \
    --EndTime $(date -u +%FT%TZ) \
    --Period 60 \
    --InstanceId ${ecs} \
    | jq '.MonitorData.InstanceMonitorData[].CPU') )

for u in ${load[@]}; do
    if [[ *" ${u} "* == " 0 1 null " ]]; then
        continue
    fi
    echo "busy"
    exit 0;
done

echo "idle"
