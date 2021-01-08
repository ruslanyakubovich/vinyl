#!/bin/php
<?php 
require_once('discogs_info.php');
define('fileCSV', 'collection.csv');
define('dAPI', 'https://api.discogs.com/releases/%s');
define('dAuthorization', sprintf('Authorization: Discogs key=%s, secret=%s', dLogin, dPass));

$Title = [
	'ID' =>  7,
	'artist' => 1,
	'tittle' =>  2,
	'released' =>  6,
	'folder' =>  8,
	'notes' =>  11
	//'json' =>  12,
];


// исключить эти папки
$folders = ['archive', 'Uncategorized'];

// оставить эти значения
$SetKeys = ["uri", "genres", "styles", "images", "thumb"];

function ClearKeys($keys, $arr){
	foreach ($arr as $k => $v) 
		if (!in_array($k, $keys))
			unset($arr[$k]);
	return $arr;
}

$csvFile = file(fileCSV);
unset($csvFile[0]);
$data = [];
$d = [];
foreach ($csvFile as $line) {
	$line = str_replace('₽', '', $line);
	$d = str_getcsv($line);
	if (in_array($d[$Title['folder']], $folders))
		continue;

	$v = ['num' => count($data)];
	foreach ($Title as $key => $value) 
		$v[$key] = $d[$value]; 
	$data[] = $v;

	// if (count($data) == 5)
	// 	break;
}



$count = count($data);
foreach ($data as $i => $v) { 
	$curlSession = curl_init();
	curl_setopt($curlSession, CURLOPT_BINARYTRANSFER, true);
	curl_setopt($curlSession, CURLOPT_RETURNTRANSFER, true);
	curl_setopt($curlSession, CURLOPT_USERAGENT, 'FooBarApp/3.0');
	curl_setopt($curlSession, CURLOPT_HTTPHEADER, [dAuthorization]);


	$u = sprintf(dAPI, $v['ID']);
	printf("%d/%d > %s\n", $i, $count, $u);
	curl_setopt($curlSession, CURLOPT_URL, $u);
	$j = json_decode(curl_exec($curlSession), true);
	$j = ClearKeys($SetKeys, $j);
	foreach ($j as $jk => $jv) 
		$data[$i][$jk] = $jv;
	
	if (rand(0,5) == rand(0,3)){
		file_put_contents('collection.json', json_encode($data));
		echo "sleep 2\n";
		sleep(2);
	}

	curl_close($curlSession);
}

file_put_contents('collection.js', 'var Vinyls = ' . json_encode($data));