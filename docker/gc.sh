#!/bin/bash -e

for c in $(docker ps -a | grep _registry_ | awk '{print $(1)}'); do
    docker exec -it ${c%$'\r'} \
        bin/registry garbage-collect \
        /etc/docker/registry/config.yml
done
