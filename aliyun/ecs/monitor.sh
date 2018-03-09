#!/bin/bash -e

ecs=${1}

stat=$($(dirname ${0})/status.sh ${ecs})
if [[ "${stat}" != "Running" ]]; then
    echo "${stat}" | tr '[:upper:]' '[:lower:]'
    exit 0
fi

load=( $(aliyuncli ecs DescribeInstanceMonitorData \
    --StartTime $(date -u +%FT%TZ -d "-30 minutes") \
    --EndTime $(date -u +%FT%TZ) \
    --Period 60 \
    --InstanceId ${ecs} \
    | jq '.MonitorData.InstanceMonitorData[].CPU') )

for u in ${load[@]}; do
    if [[ " 0 1 null " = *" ${u} "* ]]; then
        continue
    fi
    echo "busy"
    exit 0
done

echo "idle"
