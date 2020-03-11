#!/bin/sh
# Copyright (c) 2020 Polyverse Corporation

image="polyverse/php-polyscripting-builder"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)

docker build -t $image:$headsha .
docker tag $image:$headsha $image:latest


if [[ "$1" == "-p" ]]; then
	docker push $image:$headsha
	docker tag $image:$headsha $image:latest
        docker push $image:latest
fi