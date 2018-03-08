#!/bin/bash -e

ecs=${1}

aliyuncli ecs StopInstance --InstanceId ${ecs}
