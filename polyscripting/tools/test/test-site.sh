#!/bin/bash
set -e

test_site_path="./test/php-test-site"
test_files="./test/tests/"

echo "Polyscripting test files"
s_php tok-php-transformer.php -p $test_site_path
s_php tok-php-transformer.php -p $test_files --replace




cd $test_site_path

php -S localhost:8000 &
pid=$!
sleep 5

function test_failure {
	echo $1 >&2
	exit 1
}

curl http://localhost:8000/ | grep -q "Parse error"

if curl -f http://localhost:8000/ | grep -q "Parse error" ; then
	echo "SUCCESS: Vanilla site reached and returned syntax error." 
else
	 test_failure "FAILED: Non polyscripted site ran without syntax error -- polyscripting failed"
fi
kill $pid 

cd -
echo "Testing Changes Made"
if cmp -s $test_site_path"/index.php" $test_site_path"_ps/index.php"; then
	test_failure "FAILED: No differences found between index files."
else 
	echo "SUCCESS. Index files have been changed."
fi

if php -l $test_site_path/index.php; then
	test_failure "FAILED: Vanilla PHP ran successfully locally."
else
	echo "SUCCESS: Vannilla PHP threw syntax error locally."
fi

if php -l $test_site_path"_ps"; then
	echo "SUCCESS: Polyscripted PHP ran successfully locally."
else 
	"FAILED: Polyscripted PHP did not run successfully lcoally."
fi

cd $test_site_path"_ps"
echo "testing polyscripted"
php -S localhost:8000 &
sleep 5

if curl -f  http://localhost:8000/; then
	if curl -f http://localhost:8000/ | grep -q "Parse error"; then
	       test_failure "FAILED: Polyscripted Site reached, but Parse Error was Thrown."
       else
	       echo "SUCCESS: Polyscripted site reached."
	fi
else
	test_failure "FAILED: Polyscipted site could not be reached."
fi

for file in $test_files 
do
	if php -l file; then
		"SUCCES: " file
	else 
		test_failure "FAILURE: " file
	fi
done	
