<?php
/**
 * Copyright (c) 2020 Polyverse Corporation
 */

include 'snip-transform.php';
const LONG_OPTS = array("replace", "test", "dump", "phar", "inc");

set_error_handler("error_handle", E_USER_ERROR);

$replace = false;
$dump = false;
$extensions = array("php");
$root_path = "";
$out = "";
$num_ps = 0;
$is_snip = false;
$is_test = false;



arg_parse(getopt("s:p:", LONG_OPTS));

if ($is_snip ) {
    echo poly_snip($out, $is_test);
    return;
}


echo "Polyscript from dir " . $root_path . " to dir:" . $out, PHP_EOL;

if (!is_dir($out))
{
    polyscriptify($root_path, $out);
    return;
} else {
    $iterator = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($root_path, FilesystemIterator::SKIP_DOTS),
        RecursiveIteratorIterator::SELF_FIRST);

    foreach ($iterator as $fileInfo) {
        $fileOut = str_replace($root_path, $out, $fileInfo);
        if (in_array(pathinfo($fileInfo, PATHINFO_EXTENSION), $extensions)) {
            if ($dump) {
                echo "Polyscripting $fileInfo \n";
            }
            polyscriptify($fileInfo, $fileOut);
            $num_ps++;
        } else if (is_dir($fileOut)) {
            continue;
        } else if ($fileInfo->isDir() && !$replace) {
            mkdir($fileOut);
        } else if (!$replace) {
            copy($fileInfo, $fileOut);
        }
    }
}

echo "Done. Polyscripted " . $num_ps . " files\n";

function arg_parse($opts)
{
    global $dump, $root_path, $out, $replace, $is_snip;

    if ($opts['s'] != NULL && $opts['p']!=NULL) {
        trigger_error("Cannot polyscript both path and snip.", E_USER_ERROR);
    }

    if ($opts['s'] != NULL) {
        $is_snip = true;
        $out = $opts['s'];
        return;
    }

    if ($opts['p']==NULL) {
        trigger_error("Missing required argument: '-p'", E_USER_ERROR);
    }

    //Parse
    $replace = array_key_exists("replace", $opts);
    $dump = array_key_exists("dump", $opts);
    get_ext($opts);

    //Path handle
    $root_path = rtrim($opts['p'], '/');

    if (file_exists($root_path)) {
        $out = $replace ? $root_path : get_out_root($root_path);
    } else {
        trigger_error("Invalid path or file.", E_USER_ERROR);
    }
}

function get_out_root($root)
{
    $path_out = pathinfo($root, PATHINFO_DIRNAME) . "/" . pathinfo($root, PATHINFO_FILENAME) . "_ps";

    if (is_dir($root)) {
        if (!is_dir($path_out)) {
            mkdir($path_out);
        }
        return $path_out;
    } else {
        return $path_out . "." . pathinfo($root, PATHINFO_EXTENSION);
    }
}

function get_ext($opts)
{
    global $extensions, $is_test;
    if (array_key_exists("test", $opts)) { $is_test=true; array_push($extensions, "phpt"); }
    if (array_key_exists("inc", $opts)) { array_push($extensions, "inc"); }
    if (array_key_exists("phar", $opts)) { array_push($extensions, "phar"); }
}

function polyscriptify($file_name, $fileOut)
{
    global $is_test;
    $file_str = file_get_contents($file_name);
    $fp = fopen($fileOut, 'w');
    fwrite($fp, poly_snip($file_str, $is_test));
    fclose($fp);
}

function error_handle($errno, $errstr) {
    echo "Error: [$errno] $errstr\n";
    echo "Failing.";
    die();
}