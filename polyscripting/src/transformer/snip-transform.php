<?php
/**
 * Copyright (c) 2020 Polyverse Corporation
 * Created by PhpStorm.
 * User: bluegaston
 * Date: 9/28/18
 * Time: 11:30 AM
 */
const IGNORE = array(T_STRING, T_INLINE_HTML, T_CONSTANT_ENCAPSED_STRING, T_START_HEREDOC,
    T_END_HEREDOC, T_COMMENT, T_ENCAPSED_AND_WHITESPACE, T_CLOSE_TAG, T_OPEN_TAG,
    T_OPEN_TAG_WITH_ECHO);

const DICTIONARY = "/scrambled.json";
const POLY_PATH = "POLYSCRIPT_PATH";


$GLOBALS['keys_ps_map'];

class String_State
{
    public $in_str;
    public $curl_depth;
}

$str_state = new String_State();



function poly_snip($snip, $is_test)
{
    getDir(); init_str_count();

    global $tokens;

    init_str_count();

    $tokens = token_get_all($snip);
    $snipOut = "";


    for ($i = 0; $i < count($tokens); $i++) {
        $token = $tokens[$i];

        //Keep expected output for php built-in tests
        if ($is_test && check_expected($i) && ($tokens[$i + 1][1] === "EXPECT" || $tokens[$i + 1][1] == "EXPECTF")) {
            return $snipOut . grab_expected($snip, $tokens[$i + 1][1]);
        } else if (check_expected($i)) {
            $snipOut .= "--" . $tokens[++$i][1] . "--";
            $i++;
        }

        if (!is_array($token)) {
            $snipOut .= get_from_dictionary($token);

        } else {
            $snipOut .= get_tok_val($token, $i);
        }
        if ($is_test && $token[0] == "T_DEC" && check_expected($i)) {
            $snipOut .= grab_expected($snip);
            return $snipOut;
        }
    }
    return $snipOut;
}

function get_tok_val($token, $i)
{
    global $keys_ps_map, $str_state;
    $char_token_pattern = "/(\()?[A-Za-z0-9 \n]+(\))?/";

    $tok_name = token_name($token[0]);
    $tok_str = strtolower($token[1]);
    $tok_len = strlen($tok_str) - 1;

    if ($tok_name == T_DOLLAR_OPEN_CURLY_BRACES) {
        $str_state->curl_depth++;
    }

    if (!preg_match($char_token_pattern, $tok_str)) {
        if (in_array($token[0], IGNORE)) {
            return $token[1];
        } else {
            return transform_char_token($tok_str);
        }
    }

    //account for syntax of casting
    if ($tok_str[0] == "(" && $tok_str[$tok_len] == ")" && strpos($tok_name, "_CAST")) {
        $tok_str = trim($tok_str, "( )");
        if (isset ($keys_ps_map[$tok_str])) {
            return get_from_dictionary("(") . get_from_dictionary($tok_str) . get_from_dictionary(")");
        }
    }

    if (check_ignore_cases($token[0], $tok_str, $i)) {
        return $token[1];
    } else {
        return get_from_dictionary($tok_str);
    }
}

function transform_char_token($tok_str)
{
    for ($i = 0; $i < strlen($tok_str); $i++) {
        $tok_str[$i] = get_from_dictionary($tok_str[$i]);
    }
    return $tok_str;
}

function check_ignore_cases($tok_val, $tok_str, $i)
{
    global $tokens, $keys_ps_map;
    $double_colon_tag = "T_DOUBLE_COLON";

    return ((in_array($tok_val, IGNORE) || !isset ($keys_ps_map[$tok_str])) ||
        ($tok_val === T_CLASS && token_name($tokens[--$i][0]) === $double_colon_tag));
}

function get_from_dictionary($token_key)
{
    global $keys_ps_map;


    if (is_special_case($token_key)) {
        return $token_key;
    }

    if (isset($keys_ps_map[$token_key])) {
        return $keys_ps_map[$token_key];
    } else {
        return $token_key;
    }
}

function is_special_case($token_key)
{
    global $str_state;

    if ($str_state->in_str == false && $token_key != "\"") {
        return false;
    }

    if ($token_key == "\"") {
        stateFlip();
    } else if ($token_key == "{") {
        $str_state->curl_depth++;
    } else if ($token_key == "}") {
        $str_state->curl_depth--;
    }

    if ($token_key == "-" && $str_state->curl_depth == 0 ) {
        return true;
    }

    return false;
}

function stateFlip()
{
    global $str_state;

        $str_state->in_str = !$str_state->in_str;
}


function init_str_count() {
    global $str_state;
    $str_state->in_str = false;
    $str_state->curl_depth = 0;
}

function getDir()
{
    global $keys_ps_map;
    $parent = getenv(POLY_PATH);
    if ($parent == "") {
        $parent = ".";
        echo "Polyscript dictoionary not found. Looking for scrambled.json in current directory.";
    }
    $keys_ps_map = json_decode(file_get_contents($parent . DICTIONARY), TRUE)
    or exit ("Error: no polyscripting  dictionary found.");
}

//the following tests are used for .phpt files when testing expected output.
function grab_expected($snip, $tag)
{
    $expectedTag = "--".$tag."--";
    $pos = strpos($snip, $expectedTag);
    return substr($snip, $pos);
}

function check_expected($i)
{
    global $tokens;
    return ($tokens[$i][0] == T_DEC) && ($tokens[++$i][0] == T_STRING) && ($tokens[++$i][0] == T_DEC);

}