#!/bin/sh

headsha=$(git rev-parse --verify HEAD)

dockerfile=$1

echo $(basename $1)
if [ ! $(basename $1) == "Dockerfile" ]; then
    echo "Must pass dockerfile as argument."
    exit 1
fi

line="FROM polyverse/php-polyscripting-builder:$headsha as builder"
pattern="FROM polyverse\/php-polyscripting-builder:$headsha as builder"

enable='\n#add polyscripting\n
ENV POLYSCRIPT_PATH "/usr/local/bin/polyscripting"\n
ENV PHP_SRC_PATH "/usr/src/php"\n
WORKDIR $POLYSCRIPT_PATH\n
COPY --from=builder /polyscripting/ ./\n'

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
echo "FROM polyverse/php-polyscripting-builder:$headsha as builder" > temp.txt
sed "/${flag}/q" $dockerfile >> temp.txt
echo $enable >> temp.txt
awk "f;/${flag}/{f=1}" $dockerfile >> temp.txt

mv temp.txt $dockerfile