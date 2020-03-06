#!/bin/sh

image="polyverse/ps-php7.2-fpm"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:alpine-$headsha .
docker push $image:alpine-$headsha

if [[ "$1" == "-p" ]]; then
    echo "Pushing as latest tag..."
    docker tag $image:alpine-$headsha $image:latest
    docker push $image:latest
fi
