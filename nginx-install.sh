#!/bin/bash
#create: fuzj
#DATE:2015-10-10
#source funcions library
       . /etc/init.d/functions

array=(
        zlib zlib-devel
        openssl openssl-devel
        pcre pcre-devel
)
for (( i=0;i<${#array[@]};i++ ))
do
        yum install -y ${array[i]} &>/dev/null
        [ $? -eq 0 ] && {
                action "yum install ${array[i]}" /bin/true 
                echo "action "yum install ${array[i]}" /bin/true" >> /tmp/web_nginx.log
                        } || {
                action "yum install ${array[i]}" /bin/false
                echo "action "yum install ${array[i]}" /bin/false" >> /tmp/web_nginx.log
                                }

done

sleep 3
##############################################download nginx########################################
cd /usr/src/
wget http://nginx.org/download/nginx-1.6.0.tar.gz
tar zxvf nginx-1.6.0.tar.gz
cd  nginx-1.6.0
./configure --prefix=/usr/local/nginx-1.6.0 --with-http_stub_status_module --with-http_ssl_module  --with-http_realip_module
if [ $? -eq 0 ];then
        make && make install
        if [ $? -eq 0 ];then
		action "make install nginx-1.6.0" /bin/true
	else
		action "make install nginx-1.6.0" /bin/false
	fi
else
         action "configure nginx-1.6.0" /bin/false
        exit
fi
ln -s /usr/local/nginx-1.6.0 /usr/local/nginx
mkdir -p /usr/local/nginx-1.6.0/conf/vhosts
action 'install nginx is ok' /bin/true