#!/bin/bash
# Copyright (c) 2020 Polyverse Corporation

copy_dependencies() {
        cp -n $PHP_EXEC/php $PHP_EXEC/s_php
        cp -n $PHP_EXEC/s_php $POLYSCRIPT_PATH
        cp -n $PHP_SRC_PATH/ext/phar/phar.php $POLYSCRIPT_PATH
        cp -n $PHP_SRC_PATH/Zend/zend_language_scanner.l $POLYSCRIPT_PATH
        cp -n $PHP_SRC_PATH/Zend/zend_language_parser.y $POLYSCRIPT_PATH

    
}

reset_php() {
        cp $POLYSCRIPT_PATH/phar.php $PHP_SRC_PATH/ext/phar/phar.php
        rm -f $PHP_SRC_PATH/Zend/zend_language_scanner.c
        rm -f $PHP_SRC_PATH/Zend/zend_language_parser.c
}

transform_lambda() {
        /runtime/bin/php tok-php-transformer.php -p /runtime --replace
        /runtime/bin/php tok-php-transformer.php -s "$(cat /runtime/bootstrap)" > /runtime/bootstrap
}

copy_dependencies

if [[ "$MODE" == "polyscripted" || -f $POLYSCRIPT_PATH ]]; then

        echo "===================== POLYSCRIPTING ENABLED =========================="
        echo "Setting up Polyscripting...."
	reset_php
        echo "Scrambling php source."
        ./php-scrambler

        echo "Recompiling polyscripted PHP..."
        $PHP_EXEC/s_php tok-php-transformer.php -p $PHP_SRC_PATH/ext/phar/phar.php --replace

	cd $PHP_SRC_PATH;
        make -o ext/phar/phar.php install;

        cd $POLYSCRIPT_PATH;

        echo "Transforming lambda files..."
        transform_lambda
        $PHP_EXEC/s_php tok-php-transformer.php -p ./phar.php --replace
else 
         echo "===================== POLYSCRIPTING DISABLED =========================="
         echo "To enable polyscripting set MODE = 'polyscripted'"
fi
reset_php
