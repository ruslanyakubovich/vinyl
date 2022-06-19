<?php  
$json = json_decode( file_get_contents('collection.json'), true);

foreach ($json as $id => $obj){
	printf("%d → %s\n", $obj["id"], $obj["thumb"]);
	if($obj["thumb"])
		file_put_contents("./img/{$obj["id"]}.jpg", fopen($obj["thumb"], 'r'));
	if ($id % 10 == 0)
		sleep(rand(2,5));
}

print("END\n");
