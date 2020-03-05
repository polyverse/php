#!/bin/sh

cd ..
./build.sh
cd ..

list_directories=(`find . -type f -name '*publish-image.sh*' | sed -E 's|/[^/]+$||' |sort |uniq`)

echo "Building and pushing all polyscripted php images tagged with current gitsha."

for d in $list_directories; do
    cd $d
    echo "Building images from $d"
    ls
    ./publish-image.sh
done
