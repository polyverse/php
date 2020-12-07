#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

headsha=$(git rev-parse --verify HEAD)

dockerfile=$1

echo $(basename $1)
if [[ ! $(basename $1) == "Dockerfile" ]]; then
    echo "Must pass dockerfile as argument."
    exit 1
fi

line="FROM polyverse/php-polyscripting-builder:latest as builder"
pattern="FROM polyverse\/php-polyscripting-builder:latest as builder"

enable=$(cat <<-'Message'

#add polyscripting
ENV POLYSCRIPT_PATH "/usr/local/bin/polyscripting"
ENV PHP_SRC_PATH "/usr/src/php"
WORKDIR $POLYSCRIPT_PATH
COPY --from=polyscripter /polyscripting/ ./
Message
)

if grep -qF 'FROM polyverse/php-polyscripting-builder' $dockerfile  ; then
    if grep -qF "${line}" $dockerfile; then
        echo "dockerfile already enables polyscripting."
        exit 0
    fi
    echo "Dockerfile already enables polyscripting. Old sha found. Updating sha."
    sed -i '' -e "s/.*polyverse\/php-polyscripting-builder:.*/${pattern}/" $dockerfile
    exit 0
fi

echo "No polyscritping builder found, adding polyscripting to Dockerfile"

flag="COPY docker-php-source \/usr\/local\/bin\/"
echo "FROM polyverse/php-polyscripting-builder:$headsha as polyscripter" > temp.txt
sed -e "/${flag}/q" -e 's#ENV PHPIZE_DEPS#ENV PHPIZE_DEPS bison bash#' $dockerfile >> temp.txt
echo "$enable" >> temp.txt
grep -v -e 'make -j "$(nproc)";' \
        -e 'make clean;' \
        -e 'docker-php-source delete;' \
        -e 'find -type f -name' \
	-e 'apt-get purge -y --auto-remove' \
        <(sed -e 's#make install;#\${POLYSCRIPT_PATH}/polyscript-enable;#' \
        <(awk "f;/${flag}/{f=1}" $dockerfile)) >> temp.txt

mv temp.txt $dockerfile


