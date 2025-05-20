<?php
// Simple polyfill for mbstring functions used in the Twirp client/server
if (!function_exists('mb_strlen')) {
    function mb_strlen($str) { return strlen($str); }
}
if (!function_exists('mb_substr')) {
    function mb_substr($str, $start, $length = null) { 
        return $length === null ? substr($str, $start) : substr($str, $start, $length); 
    }
}