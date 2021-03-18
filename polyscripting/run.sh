#!/bin/sh
# Copyright (c) 2020 Polyverse Corporation

image="polyverse/php-polyscripting-builder"
headsha=$(git rev-parse --verify HEAD)

docker run -it $image:$headsha bash
