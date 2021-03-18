<?php
	declare(strict_types=1);

	function square_root($number) {
  		if ($number < 0) {
    			throw new InvalidArgumentException('The number must be positive.');
  		}

  		return sqrt($number);
	}

	$number = -42;

	try {
  		$square_root = square_root($number);
	} catch (\InvalidArgumentException $e) {
  		$square_root = sqrt($number * -1) . 'i';
	}

	echo sprintf('The square root of %s is %s.', $number, $square_root);
?>
