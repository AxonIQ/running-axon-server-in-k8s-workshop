#!/usr/bin/env bash

#    Copyright 2022 AxonIQ B.V.

#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at

#        http://www.apache.org/licenses/LICENSE-2.0

#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

NS_NAME=running-ee
NODE_NAME=

Usage () {
    echo "Usage: $0 [<options>] <node-name>"
    echo ""
    echo "Options:"
    echo "  -n <name>  Namespace, default '${NS_NAME}'."
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

NODE_NAME=$1

pvcs=("events" "log")
RANDOM=$$$(date +%s)
pvc=${pvcs[$RANDOM % ${#pvcs[@]}]}

kubectl exec ${NODE_NAME} -it -- fallocate -l 5G /axonserver/${pvc}/hugefile
