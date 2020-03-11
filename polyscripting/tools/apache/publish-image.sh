#!/bin/sh
# Copyright (c) 2020 Polyverse Corporation

image="polyverse/ps-${PHP_VERSION}-${BUILD_TYPE}"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:$headsha .
docker push $image:$headsha

if [[ "$1" == "-p" ]]; then
    echo "Pushing as latest tag..."
    docker tag $image:$headsha $image:latest
    docker push $image:latest
fi
