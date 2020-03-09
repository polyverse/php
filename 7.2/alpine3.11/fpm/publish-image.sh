#!/bin/bash

image="polyverse/ps-php7.2-fpm"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)

echo "Building image $image:$headsha"
docker build -t $image:$headsha .

if [[ "$1" == "-p" ]]; then
    echo "Pushing as latest tag..."
    docker tag $image:$headsha $image:latest
    docker push $image:latest
fi
