cp /usr/local/bin/polyscripting/vanilla-save/zend_language_scanner.l $PHP_SRC_PATH/Zend/zend_language_scanner.l
cp  /usr/local/bin/polyscripting/vanilla-save/zend_language_parser.y $PHP_SRC_PATH/Zend/zend_language_parser.y
cp /usr/local/bin/polyscripting/vanilla-save/phar.php $PHP_SRC_PATH/ext/phar/phar.php
cp /usr/local/bin/polyscripting/vanilla-save/build_precommand.php $PHP_SRC_PATH/ext/phar/build_precommand.php
cd $PHP_SRC_PATH; make -j 1 install -k; cd $POLYSCRIPT_PATH;
