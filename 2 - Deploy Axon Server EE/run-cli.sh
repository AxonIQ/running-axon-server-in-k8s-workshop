#!/usr/bin/env bash

NS_NAME=running-ee

Usage () {
    echo "Usage: $0 [<options>]"
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

if [[ $# == 0 ]] ; then
    Usage
fi

CONTAINER=axoniq/axonserver-cli:latest
SERVER=$(cat ssl/axonserver-1/fqdn.txt)
TOKEN=$(cat axonserver.token)

BINDIR=../bin

COMMAND=$1
shift

kubectl run axonserver-cli --image=${CONTAINER} -n ${NS_NAME} --attach --rm --restart=Never -- ${COMMAND} -i -S https://${SERVER}:8024 -t ${TOKEN} $*