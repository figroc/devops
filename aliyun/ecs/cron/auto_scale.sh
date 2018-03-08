#!/bin/bash -e

ecs=${1}

mon="$(dirname ${0})/../monitor.sh"
if [[ "$(${mon} ${ecs})" == "idle" ]]; then
    $(dirname ${0})/../stop.sh ${ecs}
fi
