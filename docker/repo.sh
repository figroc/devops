#!/bin/bash -e

rr=${1}
repo=${3}
tag=${4}

function usage() {
    if [[ -z ${1} ]]; then
        echo "${0} <registry> <command> [options]"
        echo "commands:"
        echo "  gc: garbage collect"
        echo "  lib: list library"
        echo "  tag <lib>: list tag"
        echo "  man <lib> <tag>: show manifest"
        echo "  rmi <lib> <tag>: delete image"
        exit 1
    fi
}

case ${2} in
    gc)
        ssh ${rr} ~/devops/docker/gc.sh
        ;;
    lib)
        curl -k -XGET https://${rr}/v2/_catalog
        ;;
    tag)
        curl -k -XGET https://${rr}/v2/${repo}/tags/list
        ;;
    man)
        usage ${tag}
        curl -k -XGET https://${rr}/v2/${repo}/manifests/${tag}
        ;;
    rmi)
        usage ${tag}
        tag=$(curl -vsk -H "Accept: application/vnd.docker.distribution.manifest.v2+json" \
                   -XGET https://${rr}/v2/${repo}/manifests/${tag} 2>&1 \
                   | grep Docker-Content-Digest | awk '{print ($3)}')
        curl -k -XDELETE https://${rr}/v2/${repo}/manifests/${tag%$'\r'}
        ;;
    *)
        usage
        ;;
esac
