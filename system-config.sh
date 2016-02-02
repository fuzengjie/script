#!/bin/bash
#make by Fuzj


. /etc/init.d/functions
export LANG="en_US.UTF-8"

function check() {
	lock="/tmp/set_${FUNCNAME}.lock"
if [ -e $lock ]; then
	echo "the $FUNCNAME is alread config" 
fi

}
function jishi(){
tput sc
count=11
while true;  
do
        if [ $count -gt 0 ];then
                let count--;
                sleep 1;
                tput rc
                tput ed
                echo -n -e "\033[;36m  ....$count \033[0m"
        else
                reboot;
        fi
done
}

#hostname 配置
function hostname() {
			[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
			read  -t 5 -p "please input your hostname:__" HOSTNAME_NEW
			if [ -z $HOSTNAME_NEW ] ; then
				ip=`ifconfig eth1 | awk -F "[ :]+" '/inet addr/ {print $4}'`
				HOSTNAME_NEW=`mysql -u guest -pguest -h db.sa.beyond.com -P 3306 -e "select Hostname from sadb.host where IP='$ip'" | sed '/Hostname/d'`
			fi
			HOSTNAME_OLD=`grep -i  'HOSTNAME' /etc/sysconfig/network | cut -d "=" -f2`
			sed -i "s/HOSTNAME=${HOSTNAME_OLD}/HOSTNAME=${HOSTNAME_NEW}/g"  /etc/sysconfig/network
			HOSTNAME=`grep -i  'HOSTNAME' /etc/sysconfig/network | cut -d "=" -f2`
			action "your hostname is ${HOSTNAME} now！！" /bin/true
			touch /tmp/set_hostname.lock
}
#selinux 配置
function selinux() {
		[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
		selinux_status=`sed "/^#"/d /etc/selinux/config  | awk -F"=" '$1 ~ /^SELINUX$/ {print $2}'`
		if [ ${selinux_status} != "disabled" ];then
			sed -i "s/SELINUX=${selinux_status}/SELINUX=disabled/g" /etc/selinux/config
			sleep 1
			setenforce 0
			action "selinux is `sed "/^#"/d /etc/selinux/config  | awk -F"=" '$1 ~ /^SELINUX$/ {print $2}'` " /bin/true
		fi
		touch /tmp/set_selinux.lock
}

#防火墙iptables配置
function iptables() {
		[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
		/etc/init.d/iptables restart &>/dev/null
		/sbin/iptables -F
		/etc/init.d/iptables save  &>/dev/null
		/etc/init.d/iptables stop  &>/dev/null
		chkconfig iptables off  &>/dev/null
		action "iptables is stop" /bin/true
		touch /tmp/set_iptables.lock
}

#服务启动配置
function service() {
		[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
		  for service in `chkconfig --list  | grep 3:on | awk  '{print $1}'`; do chkconfig $service off ; done
		  for service in network rsyslog crond sshd;do chkconfig $service on;done
		  [ $? -eq 0 ] && /action "the service is OK"  /bin/true 
		  echo "the `chkconfig --list  | grep 3:on | awk  '{print $1}' | tr '\n' ','` is on now "
		  touch /tmp/set_services.lock
}

#系统语言环境配置
function language() {
		[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
			language_old=`awk -F"=" '$1 ~ /^LANG$/ {print $2}' /etc/sysconfig/i18n`
			language_new="en_US.UTF-8"
			sed -i "s/LANG=${language_old}/LANG=${language_new}/g" /etc/sysconfig/i18n
			[ $? -eq 0 ] && action "system language is `awk -F"=" '$1 ~ /^LANG$/ {print $2}' /etc/sysconfig/i18n` " /bin/true
 			touch /tmp/set_language.lock
 }

 #ntp时间同步配置
 function ntp() {
 			[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
			zone_old=`grep -w ZONE /etc/sysconfig/clock | awk -F"=" '{print $2}'`
			zone_new='Asia/Shanghai'
			sed -i "s#ZONE=${zone_old}#ZONE=${zone_new}#g" /etc/sysconfig/clock
			rm -fr /etc/localtime
			cp -f  /usr/share/zoneinfo/Asia/Shanghai /etc/localtime 
			/usr/sbin/ntpdate pool.ntp.org &>/dev/null
			[ $? -eq 0 ] && action "the time update now `date +%F-%H:%M:%S` " /bin/true || action "the time update now `date +%F-%H:%M:%S`" /bin/true
 			echo '#time sync by fuzj at 2015-10-10'>>/etc/crontab
			echo '*/10 * * * * /usr/sbin/ntpdate ntp.sa.beyond.com >/dev/null 2>&1'>>/etc/crontab
			touch /tmp/set_ntp.lock
 }
 
#内核参数配置
function kernal() {
			[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
		cat >> /etc/sysctl.conf <<EOF
net.ipv4.tcp_fin_timeout = 30
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_keepalive_time = 1200
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.tcp_max_tw_buckets = 10000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384
net.netfilter.nf_conntrack_max = 25000000
net.netfilter.nf_conntrack_tcp_timeout_established = 180
net.netfilter.nf_conntrack_tcp_timeout_time_wait = 120
net.netfilter.nf_conntrack_tcp_timeout_close_wait = 60
net.netfilter.nf_conntrack_tcp_timeout_fin_wait = 120
EOF
modprobe ip_conntrack
echo "modprobe ip_conntrack" >> /etc/rc.local
/sbin/sysctl -p &>>/dev/null 
[ $? -eq 0 ] && action "the kernal is OK "  /bin/true || action "the kernal config false"
touch /tmp/set_kernal.lock
}

function ulimit_config() {
	[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
	sed -i '$d' /etc/security/limits.conf
	sed -i '$d' /etc/security/limits.conf

	cat >>/etc/security/limits.conf <<EOF

*               soft    nofile          65000
*               hard    nofile          65535
root            soft    sigpending      600000
root            hard    sigpending      600000
root            soft    stack           102400
root            hard    stack           102400
root            soft    core            1000000
root            hard    core            1000000
work            soft    sigpending      600000
work            hard    sigpending      600000
work            soft    stack           102400
work            hard    stack           102400
work            soft    core            1000000
work            hard    core            1000000
EOF
[ $? -eq 0 ] && action "the ulimit config 65535 is ok" /bin/true
touch /tmp/set_ulimit.lock
}
#ssh及系统账户配置
function ssh () {
	[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
	listen_ip=`ifconfig eth1 | sed -n '/inet addr:/p' | awk '{print $2}'| cut -d ":" -f2`
	sed -i 's/#PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config
	sed -i 's/#UseDNS yes/UseDNS no/g' /etc/ssh/sshd_config
	sed -i "s/#ListenAddress 0.0.0.0/ListenAddress $listen_ip/g" /etc/ssh/sshd_config 
	echo "AllowUsers fuzj" >> /etc/ssh/sshd_config
	groupadd -g 80 work
	useradd -g work -G work -u 80 work -s /sbin/nologin
	useradd -g work fuzj 
 	echo "fuzj123" | passwd --stdin fuzj &> /dev/null
	wget -P ~fuzj/.ssh/ http://sa.beyond.com/script/authorized_keys --http-user=sa  --http-password=sa123
	chown -R fuzj.work ~fuzj/.ssh/ && chmod 600  ~fuzj/.ssh/authorized_keys && chmod 700 ~fuzj/.ssh
 	/etc/init.d/sshd restart &> /dev/null && action  "ssh is config ok ,please used fuzj login " /bin/true
 
 cat >> /etc/profile.d/history.sh <<EOF
	export LC_ALL=C
	TMOUT=3600
	HISTFILESIZE=2000
	HISTSIZE=2000
	HISTTIMEFORMAT="%Y%m%d-%H%M%S:"
	export HISTTIMEFORMAT
	export PROMPT_COMMAND='{ command=\$(history 1 | { read x y; echo \$y; });logger -p local1.notice -t bash -i "user=\$USER,ppid=\$PPID,from=\$SSH_CLIENT,pwd=\$PWD,command:\$command"; }'
EOF
	echo "sshd:192.168.254.*:allow" >> /etc/hosts.allow
	echo "sshd:ALL:deny" >>/etc/hosts.deny
	source  /etc/profile
cat >> /etc/bashrc << EOF
if [ \$USER == "root" ];then
        PS1='\[\e[35m\]|\#|\[\e[m\][\[\e[31m\]\u\[\e[m\]@\[\e[33m\]\h \[\e[m\]\w]\\\$'
else
        PS1='\[\e[35m\]|\#|\[\e[m\][\[\e[32m\]\u\[\e[m\]@\[\e[33m\]\H \[\e[m\]\w]\\\$'
fi
EOF

source /etc/bashrc
touch /tmp/set_ssh.lock
}

#下载必备常用软件
function software() {
	[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
	    rm -fr /etc/yum.repos.d/*
            wget --http-user=sa  --http-password=sa123  http://sa.beyond.com/script/local.repo -P /etc/yum.repos.d/
            yum clean all
	    yum install lrzsz wget elinks jq htop sysstat nc   -y &>/dev/null
	   [ $? -eq 0 ] && action "lrzsz wget elinks  htop sysstat nc install"  /bin/true|| action "lrzsz wget elinks  htop sysstat nc install" /bin/false
	   touch /tmp/set_software.lock
}

#禁用ipv6
function ipv6_disable() {
	[ -e /tmp/set_${FUNCNAME}.lock ] && {
				echo "the $FUNCNAME is already config"
				return
			}
	echo "install ipv6 /bin/true" > /etc/modprobe.d/disable-ipv6.conf
	/sbin/chkconfig ip6tables off
	echo "NETWORKING_IPV6=no" >>/etc/sysconfig/network
	[ -e /etc/sysconfig/network-scripts/ifcfg-eth1 ] && echo "IPV6INIT=no 
IPV6_AUTOCONF=no" >> /etc/sysconfig/network-scripts/ifcfg-eth1
	[ -e /etc/sysconfig/network-scripts/ifcfg-eth0 ] && echo "IPV6INIT=no 
IPV6_AUTOCONF=no" >> /etc/sysconfig/network-scripts/ifcfg-eth0
action "ipv6_disable is ok " /bin/true
	touch /tmp/set_ipv6_disable.lock
}

function post_dns() {
	        [ -e /tmp/set_${FUNCNAME}.lock ] && {
                                echo "the $FUNCNAME is already config"
                                return
                        }
		ip=`ifconfig eth1 | awk -F "[ :]+" '/inet addr/ {print $4}'`
		HOSTNAME=`grep -i  'HOSTNAME' /etc/sysconfig/network | cut -d "=" -f2`
		curl -s -u sa:sa123 -X POST -d "domain=$HOSTNAME&ip=$ip"
		touch /tmp/set_post_dns.lock
}
#执行函数
function obey() {
hostname
selinux
iptables
language
ntp
kernal
software
service
ssh
ipv6_disable
ulimit_config
post_dns
}
if [[ $LOGNAME != root ]]; then
	echo -e "\033[;31m you are not administrator !!! \033[0m"
	exit 1
fi

#执行脚本
obey


#删除无用文件，创建目录

rm -fr /root/*
mkdir -p /data/{script,logs,web,crontlog}
chown -R .work /data
chmod g+s /data 

#交互，提示，要重启，默认10s无输入自动重启
echo -e "\033[;31m system config is ok, it need to reboot \033[0m"
 echo -e "\033[;34m Press enter to continue reboot!\033[0m"
read -t 2 -p "" a
if [  ! -z $a  ]; then
	jishi
else 
	reboot
fi

