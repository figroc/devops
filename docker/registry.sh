#!/bin/bash

rr=${1}
repo=${3}
tag=${4}

function usage() {
    echo "${0} <registry> <command> [options]"
    echo "commands: "
    echo "  repo: list repos "
    echo "  tag <repo>: list tags list "
    echo "  man <repo> <tag>: show image "
    echo "  rmi <repo> <ref>: delete image "
    exit 1
}

case ${2} in
    repo)
        curl -k -XGET https://${rr}/v2/_catalog
        ;;
    tag)
        curl -k -XGET https://${rr}/v2/${repo}/tags/list
        ;;
    man)
        if [[ -z ${tag} ]]; then
            usage ${0}
        fi
        curl -k -XGET https://${rr}/v2/${repo}/manifests/${tag}
        ;;
    rmi)
        if [[ -z ${tag} ]]; then
            usage ${0}
        fi
        curl -k -XDELETE https://${rr}/v2/${repo}/manifests/${tag}
        ;;
    *)
        usage ${0}
        ;;
esac
