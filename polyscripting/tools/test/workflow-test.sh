#!/bin/bash
set -ex 

image=`docker images | awk '{print $1}' | awk 'NR==2'`
polyscript_dir="/usr/local/bin/polyscripting"
container="test-build"
git_root=`git rev-parse --show-toplevel`

echo $image

echo "Running image"
docker run --name test-build -tid $image bash
docker exec -w $polyscript_dir $container $polyscript_dir/build-scrambled.sh
echo "copying test"
docker cp $git_root/polyscripting/tools/test/ $container:$polyscript_dir
echo "exec build"
docker exec -w $polyscript_dir $container ./test/test-site.sh


docker rm -f $container
