#!/bin/php
<?php 
require_once('discogs_info.php');
define('fileCSV', 'collection.csv');
define('dAPI', 'https://api.discogs.com/releases/%s');
define('dAuthorization', sprintf('Authorization: Discogs key=%s, secret=%s', dLogin, dPass));

$Title = [
	'ID' =>  7,
	'artist' => 1,
	'attle' =>  2,
	'released' =>  6,
	'folder' =>  8,
	'notes' =>  11,
	'json' =>  12,
];


// исключить эти папки
$folders = ['archive', 'Uncategorized'];

$csvFile = file(fileCSV);
unset($csvFile[0]);
$data = [];
$d = [];
foreach ($csvFile as $line) {
	$d = str_getcsv($line);
	$v = [];
	if (in_array($d[$Title['folder']], $folders))
		continue;
	foreach ($Title as $key => $value) 
		$v[$key] = $d[$value];
	$data[] = $v;
}


$curlSession = curl_init();

curl_setopt($curlSession, CURLOPT_BINARYTRANSFER, true);
curl_setopt($curlSession, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curlSession, CURLOPT_USERAGENT, 'FooBarApp/3.0');
curl_setopt($curlSession, CURLOPT_HTTPHEADER, [dAuthorization]);


for ($i=0; $i < 2; $i++) { 
	$u = sprintf(dAPI, $data[$i]['ID']);
	printf("%d > %s\n",$i,  $u);
	curl_setopt($curlSession, CURLOPT_URL, $u);
	$j = json_decode(curl_exec($curlSession), true);
	$data[$i]['json'] = $j;	
}

curl_close($curlSession);

file_put_contents('collection.json', json_encode($data));
