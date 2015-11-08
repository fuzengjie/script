#!/bin/bash
#
need_command=(
        vmstat
        iostat
    )
function red_echo(){
        echo -e "\033[31;49;1m $1 \033[39;49;0m"
}

function yellow_echo(){
        echo -e "\033[33;49;1m $1 \033[39;49;0m"
}
function green_echo(){
        echo -e "\033[32;49;1m $1 \033[39;49;0m"
}
if [ $LOGNAME != root ]; then
    echo "Please use the root account operation."
    exit 1
fi

for (( i = 0; i < ${#need_command[@]} ; i++ )); do
  
    if ! which ${need_command[i]} &>/dev/null; then
        red_echo " ${need_command[i]} command not found, please install."
        exit 1
    fi
        sleep 1 
done

function cpu_info() {

  PROCESSOR=`grep "processor" /proc/cpuinfo |wc -l` 
  MODEL=`grep "model name" /proc/cpuinfo |uniq|awk '{print $4,$5,$6,$7,$8,$9}'`
  SPEED=`grep "cpu MHz" /proc/cpuinfo |uniq |awk '{print $1,$2":"$4}'`
  CACHE=`awk '/cache size/ {print $1,$2":"$4$5}' /proc/cpuinfo |uniq`
  UTIL=`vmstat |awk '{if(NR==3)print 100-$15"%"}'`
  USER=`vmstat |awk '{if(NR==3)print $13"%"}'`
  SYS=`vmstat |awk '{if(NR==3)print $14"%"}'`
  IOWAIT=`vmstat |awk '{if(NR==3)print $16"%"}'`
}

function disk_info() {

    UTIL=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$NF"%"}'`
    READ=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$6"KB"}'`
    WRITE=`iostat -x -k |awk '/^[v|s]/{OFS=": ";print $1,$7"KB"}'`
    DISK_TOTAL=`fdisk -l |awk '/^Disk.*bytes/&&/\/dev/{printf $2" ";printf "%d",$3;print "GB"}'`

}

function mem_info() {

    MEM_TOTAL=`free -m |awk '{if(NR==2)printf "%.1f",$2/1024}END{print "G"}'`
    USE=`free -m |awk '{if(NR==3) printf "%.1f",$3/1024}END{print "G"}'`
    FREE=`free -m |awk '{if(NR==3) printf "%.1f",$4/1024}END{print "G"}'`
    CACHE=`free -m |awk '{if(NR==2) printf "%.1f",($6+$7)/1024}END{print "G"}'`
}

function tcp_status() {

    COUNT=`netstat -ant |awk '{status[$NF]++}END{for(i in status) print i,status[i]}'`
}

function load_info() {

    Load1=$(awk '{print $1}' /proc/loadavg)
    Load5=$(awk '{print $2}' /proc/loadavg)
    Load10=$(awk '{print $3}' /proc/loadavg)
}

function network() {
    
 for eth in `ls /etc/sysconfig/network-scripts/ | grep ifcfg | awk -F"-" '{print $2}'`
do

    OLD_IN=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==5)print $6}'`
    OLD_OUT=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==7)print $6}'`
    sleep 1
    NEW_IN=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $4;else if(NR==5)print $6}'`
    NEW_OUT=`ifconfig $eth |awk -F'[: ]+' '/bytes/{if(NR==8)print $9;else if(NR==7)print $6}'`
    IN=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_IN}-${OLD_IN}))'/1024}'`
    OUT=`awk 'BEGIN{printf "%.1f\n",'$((${NEW_OUT}-${OLD_OUT}))'/1024}'`
done
}

