#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation
set -e

type="$(basename $PWD)"
build="$(basename $(dirname $PWD))"
php_ver="$(basename $(dirname $(dirname $PWD)))"
image="polyverse/ps-php${php_ver}-${build}-${type}"

echo "Image $image being built"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)

echo "Building image $image:$headsha"
docker build -t $image:$headsha .
docker tag $image:$headsha $image:latest

if [[ "$1" == "-p" ]]; then
    echo "Pushing as latest tag..."
    docker push $image:$headsha
    docker push $image:latest
fi

if [[ "$1" == "-g" ]]; then
	echo "Pushing to Github Container Repository"
	docker tag $image:$headsha ghcr.io/$image:$headsha
	docker tag $image:$headsha ghcr.io/$image:latest
	docker push ghcr.io/$image:$headsha
	docker push ghcr.io/$image:latest
fi

if [[ "$1" == "run" ]]; then
	docker run -it $image bash
fi
