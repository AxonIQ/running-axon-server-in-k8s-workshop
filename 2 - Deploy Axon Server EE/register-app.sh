#!/usr/bin/env bash

NS_NAME=running-ee

Usage () {
    echo "Usage: $0 [<options>]"
    echo ""
    echo "Options:"
    echo "  -n <name>  Namespace to use, default '${NS_NAME}'."
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

if [[ $# != 0 ]] ; then
    Usage
fi

APP_NAME=
APP_TOKEN=
APP_ROLE=USE_CONTEXT@default

CONTAINER=axoniq/axonserver-cli:latest
SERVER=$(cat ssl/axonserver-1/fqdn.txt)
TOKEN=$(cat axonserver.token)

BINDIR=../bin

APP_TOKEN_FILE=./quicktester.token
${BINDIR}/gen-token.sh ${APP_TOKEN_FILE}
APP_TOKEN=$(cat ${APP_TOKEN_FILE})

kubectl run axonserver-cli --image=${CONTAINER} -n ${NS_NAME} --attach --rm -- register-application -i -S https://${SERVER}:8024 -t ${TOKEN} -a quicktester -T ${APP_TOKEN} -r ${APP_ROLE}