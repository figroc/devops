#!/bin/bash -e

source ${1}

mon="$(dirname ${0})/../monitor.sh"
for ecs in ${SPOOL[@]}; do
    if [[ "$(${mon} ${ecs})" == "idle" ]]; then
        $(dirname ${0})/../stop.sh ${ecs}
    fi
done
