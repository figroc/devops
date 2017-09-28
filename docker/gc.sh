#!/bin/bash -e

for c in $(docker ps -a | grep _registry_ | awk '{print $(3)}'); do
    docker exec -it ${c%$'\r'} \
        bin/registry garbage-collect \
        /etc/docker/registry/config.yml \
done
