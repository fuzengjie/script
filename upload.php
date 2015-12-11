<?php   
$UP_DIR = '/data/upload/';
$SOURCE_DIR = "/data/source/";
$YUM_DIR = "/data/repo";
$SCRIPT_DIR="/data/script/";
if ($_FILES['file']['name'] != '') {  
    if ($_FILES['file']['error'] > 0) {  
        echo "upload false<br/>";  
    }  
    else {  
$name=$_FILES['file']["name"];//上传文件的文件名 
$type=$_FILES['file']["type"];//上传文件的类型 
$size=$_FILES['file']["size"];//上传文件的大小 
$tmp_name=$_FILES['file']["tmp_name"];//上传文件的临时存放路径
$url=("http://sa.beyond.com/".$name);//访问的URL
$suffix=substr(strrchr($name,"."),1);
$prefix=substr($name , 0 , 6);
        if ($suffix == 'gz' || $suffix == 'bz2') {
                $DST_DIR=$SOURCE_DIR;
        }
         elseif ($suffix == 'rpm' && $prefix == 'beyond') {
                $DST_DIR=($YUM_DIR."/beyond/Package");
                }
         elseif ($suffix == 'rpm' && $prefix != 'beyond') {
                $DST_DIR=($YUM_DIR."/extend/Package");
                }
        elseif ($suffix == 'sh' || $suffix == 'py' || $suffix == 'php') {
                $DST_DIR=$SCRIPT_DIR;
        }
        else { $DST_DIR=$UP_DIR;
	 }

echo "=================================<br/>"; 
echo "Upload FileName: ".$name."<br/>"; 
echo "Upload FileType: ".$type."<br/>"; 
echo "upload FileSize: ".$size."<br/>"; 

        if (move_uploaded_file($_FILES['file']['tmp_name'], $DST_DIR.$_FILES['file']['name'])) {  
	    echo "Upload  FileStatus: success<br/>";  
	    echo "Access URL:".$url."<br/>";
       }  else {  
            echo "Upload FileStatus: false<br/>";  
        }  
    } 
echo "==================================<br/>";
}
else {  
	    echo "please choose a file<br/>";  
}
?>
