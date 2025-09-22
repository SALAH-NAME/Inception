<?php

$path = preg_replace('/^\/adminer\//', '', parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH));
$file = '/var/www/html/' . $path;

if (file_exists($file) && is_file($file)) {
    $mime_types = [
        'css' => 'text/css',
        'js' => 'application/javascript',
        'png' => 'image/png',
        'jpg' => 'image/jpeg',
        'gif' => 'image/gif',
        'ico' => 'image/x-icon',
        'svg' => 'image/svg+xml'
    ];
    
    $ext = pathinfo($file, PATHINFO_EXTENSION);
    if (isset($mime_types[$ext])) {
        header('Content-Type: ' . $mime_types[$ext]);
        header('Cache-Control: public, max-age=31536000');
        readfile($file);
        exit;
    }
}

http_response_code(404);
?>