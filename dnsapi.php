<?php
$file='/usr/local/dnspod-sr/conf/root.z';
$method = $_SERVER['REQUEST_METHOD'];
parse_str(file_get_contents('php://input'), $data);
$domain=$data['domain'];
$ip=$data['ip'];
$ttl=$data['ttl'];
$type=$data['type'];
$new_ip=$data['newip'];
if ($method == "POST") {

	if ($ttl == "" || $type == "") {
		$ttl="36000";
		$type="A";
	}
	if ($domain == "" || $ip == "") {
		echo "no domain or ip";
		exit;
	}

	$str=($domain." ".$ttl." IN ".$type." ".$ip."\r\n");
	$content = fopen($file,"a+");
	fwrite($content,$str);
	fclose($content);
	}
elseif ($method == "DELETE") {
	$content=file($file);
	foreach($content as $key => $values) {
		if (strpos($values,$domain) !== false && strpos($values,$ip)) {
			unset($content[$key]);
		}
	}
	file_put_contents($file,$content);
}
elseif ($method == "UPDATE") {
	$content=file($file);
	foreach($content as $key => $values) {
		if (strpos($values,$domain) !== false && strpos($values,$ip)) {
			$n=$content[$key];
			$content[$key]=str_replace($ip,$new_ip,$n);
		}
	}
	file_put_contents($file,$content);
}
elseif ($method == "SELECT"){
	$content=file($file);
	foreach($content as $key => $values) {
                if (strpos($values,$domain) !== false ||  strpos($values,$ip)) {
			$str=explode(" ",$content[$key]);
			echo json_encode(array('IP' => chop($str[4]),'Type' => $str[3],'TTL' => $str[1],'Domain' => $str[0] ));
		}
        }

}

?>

