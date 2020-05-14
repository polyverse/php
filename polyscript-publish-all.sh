#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation
set -ex
ROOT=$PWD
cd ./polyscripting
./build.sh -p
cd $ROOT

FILES=$(find . -path ./polyscripting -prune -o -type f -name 'publish-image.sh' -print | sed -E 's|/[^/]+$||' |uniq)

echo $FILES
echo "Building and pushing all polyscripted php images tagged with current gitsha."
for d in $FILES; do
	cd $d
	echo "building and publishing $d"
	./publish-image.sh -p > /dev/null  
	cd $ROOT
	echo $PWD
done
