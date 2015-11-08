#!/bin/bash


if [ $LOGNAME != root ]; then
    echo "Please use the root account operation."
    exit 1
fi


read -p "please input the name: " name
read -p "please input the mac addr:" mac
read -p "please input the ip addr:" ip

if [ ! -z $name ] || [ ! -z $mac ] || [ ! -z $ip ]
then

/usr/bin/cobbler system add --name=$name --mac=$mac --ip-address=$ip --subnet=255.255.255.0 --gateway=192.168.254.1 --interface=eth1 --static=1 --profile=CentOS-6.4-x86_64 --name-servers="192.168.254.254"

/usr/bin/cobbler sync  &>/dev/null
[ $? -eq 0 ] && echo "cobbler is config ok" || echo "cobbler is config false"

else
	echo "input error !!!"
fi
