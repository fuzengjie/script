<?php   
$UP_DIR = '/data/upload/';
$SOURCE_DIR = "/data/source/";
$YUM_DIR = "/data/repo";
$SCRIPT_DIR="/data/script/";
if ($_FILES['file']['name'] != '') {  
    if ($_FILES['file']['error'] > 0) {  
        echo "upload false";  
    }  
    else {  
$name=$_FILES['file']["name"];//上传文件的文件名 
$type=$_FILES['file']["type"];//上传文件的类型 
$size=$_FILES['file']["size"];//上传文件的大小 
$tmp_name=$_FILES['file']["tmp_name"];//上传文件的临时存放路径
$url=("http://sa.beyond.com/".$name);//访问的URL
$suffix=substr(strrchr($name,"."),1);
$prefix=substr($name , 0 , 6);
        if ($suffix == 'gz' || $suffix == 'bz2' || $suffix == 'zip' || $suffix == 'tgz') {
                $DST_DIR=$SOURCE_DIR;
        }
         elseif ($suffix == 'rpm' && $prefix == 'beyond') {
                $DST_DIR=($YUM_DIR."/beyond/Packages/");
                }
         elseif ($suffix == 'rpm' && $prefix != 'beyond') {
                $DST_DIR=($YUM_DIR."/extend/Packages/");
                }
         elseif ($suffix == 'sh' || $suffix == 'py' || $suffix == 'php') {
                $DST_DIR=$SCRIPT_DIR;
        	}
        else { $DST_DIR=$UP_DIR;
	 	}
        if (move_uploaded_file($_FILES['file']['tmp_name'], $DST_DIR.$_FILES['file']['name'])) {  
	    	$status="success";
       	  }
	  else {  
		$status="false";
		$url='none';
           }
	echo json_encode(array('FileURL'=> $url,'status'=>$status,'FileSize'=> $size,'FileType'=> $type,'FileName'=>$name));
    } 
}
else {  
	    echo "please choose a file";  
}
?>
