#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

if [ ! -v PHP_EXEC ]; then
	PHP_EXEC=/usr/local/bin
fi

if [ ! -f "${PHP_EXEC}/s_php" ]; then
     # Make default php not work
     mv $PHP_EXEC/php $PHP_EXEC/s_php
else
     rm $PHP_EXEC/php
fi

./save-current-scramble.sh vanilla-save
./php-scrambler

OWD=$PWD

if [ -f $PHP_SRC_PATH/ext/phar/phar.php ]; then
     # Scramble the phar.php file so it compiles with the new PHP
     cp $PHP_SRC_PATH/ext/phar/phar.php .
     $PHP_EXEC/s_php tok-php-transformer.php -p ./phar.php --replace
     mv ./phar.php $PHP_SRC_PATH/ext/phar/phar.php
else
     echo "NO SUCH FILE at scramble time: $PHP_SRC_PATH/ext/phar/phar.php"
fi

if [ -f $PHP_SRC_PATH/ext/phar/build_precommand.php ]; then
     # Scramble the phar.php file so it compiles with the new PHP
     cp $PHP_SRC_PATH/ext/phar/build_precommand.php .
     $PHP_EXEC/s_php tok-php-transformer.php -p ./build_precommand.php --replace
     mv ./build_precommand.php $PHP_SRC_PATH/ext/phar/build_precommand.php
else
     echo "NO SUCH FILE at scramble time: $PHP_SRC_PATH/ext/phar/phar.php"
fi

cd $PHP_SRC_PATH; make -j 1 -o ext/phar/phar.php install -k; cd $POLYSCRIPT_PATH;
