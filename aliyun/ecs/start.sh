#!/bin/bash -e

ecs=${1}

aliyuncli ecs StartInstance --InstanceId ${ecs}
