#!/usr/bin/env bash

NS_NAME=running-ee

Usage () {
    echo "Usage: $0 [<options>] <node-name>"
    echo ""
    echo "Options:"
    echo "  -n <name>  Namespace to deploy to, default '${NS_NAME}'."
    exit 1
}

options=$(getopt 'n:' "$@")
[ $? -eq 0 ] || {
    Usage
}
eval set -- "$options"
while true; do
    case $1 in
    -n)    NS_NAME=$2       ; shift ;;
    --)
        shift
        break
        ;;
    esac
    shift
done

if [[ $# != 1 ]] ; then
    Usage
fi

CONTAINER=ubuntu:latest
NODE=$1

kubectl run bash --image=${CONTAINER} -n ${NS_NAME} -i -q --rm --restart=Never --command \
    -- /bin/bash -c 'apt-get update >/dev/null 2>&1 ; apt-get install -y curl jq >/dev/null 2>&1 ; curl -ks https://'${NODE}':8024/actuator/health | jq'