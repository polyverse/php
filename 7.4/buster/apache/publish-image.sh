#!/bin/sh

image="polyverse/ps-php7.4-apache"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker build -t $image:$headsha .

if [[ "$1" == "-p" ]]; then
	docker push $image:$headsha
	echo "Pushing as latest tag..."
	docker tag $image:$headsha $image:latest
	docker push $image:latest
fi

if [[ "$1" == "-g" ]]; then
        echo "Pushing to Github Container Repository"
        docker tag $image:$headsha ghcr.io/$image:$headsha
        docker push ghcr.io/$image:$headsha
fi
