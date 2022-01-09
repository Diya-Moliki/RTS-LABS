#!/bin/bash

cd `dirname $0`

while test $# != 0
do
    case "$1" in
    -f) FORCE=yes ;;
    esac
    shift
done

if [[ ! $FORCE ]] && [[ -f sqs-cleanup.zip ]]; then
    echo File already built
    exit
fi

docker build -t sqs-cleanup-build .

docker run \
    -v $(pwd):/work \
    sqs-cleanup-build \
    sh -c 'cp /src/sqs-cleanup.zip /work && chown 1000:1000 /work/sqs-cleanup.zip'

