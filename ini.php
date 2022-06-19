<?php 

define('dAuthorization', sprintf('Authorization: Discogs token=%s', file_get_contents('token')));
define('dFolder', 'https://api.discogs.com/users/roosyak/collection/folders/%d');

$fID = [
	// folder id => name 
	2217526 => '100',  
	2217532 => '200',
	2217528 => '300',
	2084754 => '50',
	2217537 => '500',
	2217529 => '500+',
];

// оставить эти значения
$SetKeys = ["genres", "styles", "thumb", "country", "labels", 
"title", "year", "artists", "notes"];

function ClearKeys($keys, $arr){
	foreach ($arr as $k => $v)
		if (!in_array($k, $keys))
			unset($arr[$k]);
		
	if (isset($arr["styles"])){
		$arr["genres"] = array_merge($arr["styles"], $arr["genres"]);
		$arr["genres"] = is_array($arr["genres"])? join(', ', $arr["genres"]) : $arr["genres"];
		unset($arr["styles"]);
	}
	foreach($arr["artists"] as $k => $v)
		$arr["artists"][$k] = $v["name"];
	$arr["artists"] = join(', ', $arr["artists"]);


	foreach($arr["labels"] as $k => $v)
		$arr["labels"][$k] = $v["name"];
	$arr["labels"] = join(', ', $arr["labels"]);
	
	return $arr;
}

function GetUrl($session, $url){ 
	printf("GET \t%s \n", $url);
	curl_setopt($session, CURLOPT_URL, $url);
	$d = json_decode(curl_exec($session), true); 
	printf("%d\titems\n", count($d['releases']));

	if (isset($d["pagination"]['urls']['next'])){ 
		printf("NEXT \t%s \n", $url);
		$d2 = GetUrl($session, $d["pagination"]['urls']['next']); 
		$d["releases"] = array_merge($d["releases"], $d2["releases"]);
	}

	return $d;
}

$r = [];
$curlSession = curl_init();
curl_setopt($curlSession, CURLOPT_BINARYTRANSFER, true);
curl_setopt($curlSession, CURLOPT_RETURNTRANSFER, true);
curl_setopt($curlSession, CURLOPT_USERAGENT, 'FooBarApp/3.0');
curl_setopt($curlSession, CURLOPT_HTTPHEADER, [dAuthorization]);

foreach ($fID as $id => $name) {
	$url = sprintf(dFolder, $id ); 
	printf("[%s]\t%s\t%s \n", $name,   $id,  $url);
	
	$d = GetUrl($curlSession, $url. '/releases?per_page=100'); 

	printf("[%s]\t%d \n\n", $name, count ($d["releases"]));

	foreach($d["releases"] as $k => $v){
		if (isset($v["notes"])){
			foreach($v["notes"] as $k2 => $v2)
				$v["notes"][$k2] = $v2["value"];
			$v["notes"] = join(', ', $v["notes"]);
		}

		$d["releases"][$k] = array_merge($v, ClearKeys($SetKeys, $v["basic_information"]));
		$d["releases"][$k]['folder'] = $name; 	
		unset($d["releases"][$k]["basic_information"] );
	}

	$r = array_merge($r, $d["releases"]);
	file_put_contents('collection.json', json_encode($r));
}
printf("ALL = %d \n\n", count($r));

