<?php  
$json = json_decode( file_get_contents('collection.json'), true);

foreach ($json as $id => $obj){
	file_put_contents("./img/{$obj["id"]}.jpg", fopen($obj["thumb"], 'r'));
	if ($id % 10 == 0)
		sleep(2);
}

