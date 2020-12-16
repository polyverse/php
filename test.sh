#!/bin/bash

cd polyscripting
./build.sh

cd ../8.0/buster/apache
./publish-image.sh

image="polyverse/ps-php8.0-apache"

echo "$(date) Obtaining current git sha for tagging the docker image"
headsha=$(git rev-parse --verify HEAD)


docker run --rm -it $image:$headsha bash
