#/bin/bash

#Step 1. 判断系统有2块以上磁盘同则开始循环
DISK_COUNTS=`fdisk -l|grep ^Disk|grep dev|grep -v "sda"|wc -l`
for ((i=1;i<=$DISK_COUNTS;i++))
   do
	 DISK_LISTS=`fdisk -l|grep ^Disk|grep dev |cut -c6-13`
	 echo -ne "\033[30;32m \n\nThese disks are available for use:\n$DISK_LISTS\n\n \033[0m"
	#Step 2.交互式确认是否要对第二块磁盘处理，输入不合法则自动要求重新输入
	 Disk=`echo $DISK_LISTS| grep -v "sda" |tr " " "\n"| sed -n ${i}p`
	 read  -t 3 -p " Do you want to partion $Disk and mount it ? [Y/y/N/n]  " ANSWER
	 [ -z $ANSWER ]  && ANSWER="y"
	 case $ANSWER in
	        [Yy])
	#确认sdb未被分区
	             if [ `fdisk -l $Disk|grep ${Disk}1 |wc -l` -eq 0 ]; then
	              [ -e /data ] || mkdir -p /data
	#因为测试了很久,将fdisk集成在一个shell文件会提示错误," invalid end of file."，所以生成一个临时文件/tmp/mount2disk_arg.sh,这个小脚本用于将/dev/sdbd磁盘划分成一个分区
	                SIZE_CYLINDERS=`fdisk -l $Disk |grep 'cylinders$'|awk '{print $5}'`
	                echo -ne "#!/bin/bash\nfdisk $Disk << EOF > /dev/null\n"> /tmp/mount2disk_arg.sh
	                echo -ne "n\np\n1\n1\n$SIZE_CYLINDERS\nw\nq\nEOF\n" >> /tmp/mount2disk_arg.sh
	                chmod u+x /tmp/mount2disk_arg.sh && /tmp/mount2disk_arg.sh
	                sleep 1
	                mkfs.ext4 ${Disk}1 > /dev/null
	                mount ${Disk}1 /data && echo -ne "${Disk}1\t\t/data\t\t\text4\tdefaults,noatime\t0 0\n" >> /etc/fstab
	                echo -ne "\033[30;32m \nIt's done,See The output for command 'mount':\n\n \033[0m" && mount |grep /data
	              else
	                echo -ne "\033[30;31m do not have second disk or already had a partion.quit without proceed.\n \033[0m"
	              fi
	              break
	        ;;
	        [Nn])
	            echo -ne "\033[30;32m As you wish,did not proceed /dev/sdb.\n \033[0m"
	            break
	        ;;
	        *)
	          echo -ne "\033[30;31m Invalied input. only accept [Y/y/N/n].\n \033[0m"
	        ;;
	 esac
done

#rm -f  /tmp/mount2disk_arg.sh
