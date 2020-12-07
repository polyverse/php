#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

cd ..
./build.sh 
cd ..

ROOT=$PWD
FILES=$(find . -name polyscripting -prune -o -type f -name '*publish-image.sh*' | sed -E 's|/[^/]+$||' |uniq)

echo $FILES
echo "Building and pushing all polyscripted php images tagged with current gitsha."
for d in $FILES; do
	cd $d
	echo "building and publishing $d"
	./publish-image.sh 
	cd $ROOT
done
