#!/bin/sh

image="polyverse/ps-php7.2-fpm"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:$headsha .
docker push $image:$headsha

echo "Pushing as latest tag..."
docker tag $image:$headsha $image:latest
docker push $image:latest

