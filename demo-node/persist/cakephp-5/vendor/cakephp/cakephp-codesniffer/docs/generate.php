#!/usr/bin/env php
<?php
$phar = file_exists(dirname(__DIR__) . DIRECTORY_SEPARATOR . 'composer.phar');
$command = ($phar ? 'php composer.phar' : 'composer') . ' explain';

exec($command, $output, $ret);
if ($ret !== 0) {
    exit('Invalid execution. Run from ROOT after composer install etc as `composer docs`.');
}

foreach ($output as &$row) {
    $row = str_replace('  ', '- ', $row);
}
unset($row);

$content = implode(PHP_EOL, $output);

$content = <<<TEXT
# CakePHP ruleset
$content
TEXT;

$file = __DIR__ . DIRECTORY_SEPARATOR . 'README.md';

file_put_contents($file, $content);
exit($ret);
