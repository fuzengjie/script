#!/bin/bash


file=$2
URL="http://sa.beyond.com"
if [ $USER != 'root' ]
   then
	Print_Red "You are not administrator,please use root !!!..."
elif [ -z $file ]
	then
		Print_Red  "Please Choose a upload file"
  
fi

Color () {
        Print_Red () {
        echo  -e  "\033[40;31m $1  \033[0m "
        }
        Print_Green () {
        echo -e  "\033[40;32m $1 \033[0m "
        }
        Print_Yelow () {
        echo -n -e  "\033[40;33m $1 \033[0m "
        }
}

Upload() {
POST_URL="$URL/upload"
user="sa"
passwd="sa123"
POST_cmd="curl -s -u $user:$passwd -X POST -F file=@$file $POST_URL"

Print_Green  "`$POST_cmd`"

}

Download() {
user="sa"
passwd="sa123"
type=`echo $file | awk -F "." '{print $NF}'`
if [ $type == 'gz' ] || [ $type == 'bz2' ] || [ $type == 'zip' ] || [ $type == 'rar' ]
  then
	Download_URL="$URL/source"
else 
	Download_URL="$URL/script"
fi

Print_Yelow "
	please input target path
	default [/tmp]
	-->" ; read -p ""  path
if [ -z $path ] 
	then
		path="/tmp"
fi
Download_cmd="curl -s -u $user:$passwd $Download_URL/$file -o $path/$file"
Print_Green "`$Download_cmd`"

[ -e $path/$file ] && Print_Green  "download seccess, the file in $path/$file" || Print_Red "download error"
}

Color
case $1 in

-u|-upload)
	Upload
	;;
-d|-download)
	Download
	;;
*)
	Print_Red "Please use -u or -d"
esac
