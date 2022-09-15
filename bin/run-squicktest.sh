#!/usr/bin/env bash

NS_NAME=default
VERSION=4.5-SNAPSHOT
IMAGE=
TOKEN=
SECRET=
CERT=tls.crt

Usage () {
    echo "Usage: $0 [<options>]"
    echo ""
    echo "Options:"
    echo "  -n <name>      Namespace to deploy to, default '${NS_NAME}'."
    echo "  -t <token>     Token to use for the QuickTester, default none."
    echo "  -v <version>   Version of the QuickTester to use, default '${VERSION}'."
    echo "  -i <image>     The container image to deploy, if not the quicktester. Using this will override any specified version."
    echo "  -s <secret>    The name of the secret containing the certificate validating Axon Server's client port, default none."
    echo "  -c <filename>  The filename of the certificate exposed by the secret, by default '${CERT}'."
    exit 1
}

options=$(getopt 'n:t:v:i:s:c:' "$@")
[ $? -eq 0 ] || {
    Usage
}
eval set -- "$options"
while true; do
    case $1 in
    -n)    NS_NAME=$2       ; shift ;;
    -t)    TOKEN=$2         ; shift ;;
    -v)    VERSION=$2       ; shift ;;
    -i)    IMAGE=$2         ; shift ;;
    -s)    SECRET=$2        ; shift ;;
    -c)    CERT=$2          ; shift ;;
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

if [[ "${IMAGE}" == "" ]] ; then
    IMAGE=axoniq/axonserver-quicktest:${VERSION}
fi
SERVERS=$(find ssl -name fqdn.txt | xargs cat | tr -s '\n' , | sed -e 's/,$//')

if [[ "${SECRET}" != "" ]] ; then
kubectl run axonserver-quicktest --image=${IMAGE} -n ${NS_NAME} --attach stdout --rm \
--overrides='
{
  "apiVersion": "v1",
  "spec": {
    "containers": [
        {
        "name": "axonserver-quicktest",
        "image": "'${IMAGE}'",
        "env": [
            {"name": "AXON_AXONSERVER_SERVERS", "value": "'${SERVERS}'"},
            {"name": "MS_DELAY", "value": "1000"},
            {"name": "SPRING_PROFILES_ACTIVE", "value": "axonserver"},
            {"name": "AXON_AXONSERVER_SSL-ENABLED", "value": "true"},
            {"name": "AXON_AXONSERVER_CERT-FILE", "value": "/ssl/'${CERT}'"},
            {"name": "AXON_AXONSERVER_TOKEN", "value": "'${TOKEN}'"}
        ],
        "volumeMounts": [{
            "mountPath": "/ssl/'${CERT}'",
            "subPath": "'${CERT}'",
            "readOnly": true,
            "name": "cert-file"
        }]
        }
    ],
    "volumes": [{
        "name":"cert-file",
        "secret": {
            "secretName": "'${SECRET}'",
            "items": [{
                "key": "'${CERT}'",
                "path": "'${CERT}'"
            }]
        }
    }]
  }
}'
else
kubectl run axonserver-quicktest --image=${IMAGE} -n ${NS_NAME} --attach stdout --rm \
--overrides='
{
  "apiVersion": "v1",
  "spec": {
    "containers": [{
        "name": "axonserver-quicktest",
        "image": "'${IMAGE}'",
        "env": [
            {"name": "AXON_AXONSERVER_SERVERS", "value": "'${SERVERS}'"},
            {"name": "MS_DELAY", "value": "1000"},
            {"name": "SPRING_PROFILES_ACTIVE", "value": "axonserver"},
            {"name": "AXON_AXONSERVER_SSL-ENABLED", "value": "true"},
            {"name": "AXON_AXONSERVER_TOKEN", "value": "'${TOKEN}'"}
        ]
    }]
  }
}'
fi
