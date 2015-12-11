#! /bin/sh
#
# dnspod-sr     DNSPod Security Recursive DNS Server
#
# chkconfig:    2345 98 02
# description:  DNSPod Security Recursive DNS Server
# processname:  dnspod-sr
# pidfile:      /var/run/dnspod-sr.pid
# config:       /usr/local/services/dnspod-sr/etc/sr.conf

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

DNSPOD_SR=/usr/local/dnspod-sr/bin/dnspod-sr

# Source dnspod-sr configuration.
if [ -f /etc/sysconfig/dnspod-sr ] ; then
        . /etc/sysconfig/dnspod-sr
fi

[ -f $DNSPOD_SR ] || exit 0

RETVAL=0

# See how we were called.
case "$1" in
  start)
        echo -n "Starting dnspod-sr: "
        daemon $NICELEVEL $DNSPOD_SR > /dev/null 2>&1 &
        RETVAL=$?
        [ $RETVAL = 0 ] && { 
           action "" /bin/true ; touch /var/lock/subsys/dnspod-sr
           } ||  action "" /bin/false
	;;
  stop)
        echo -n "Stopping dnspod-sr: "
        killproc dnspod-sr
        RETVAL=$?
        echo
        [ $RETVAL = 0 ] && rm -f /var/lock/subsys/dnspod-sr
        ;;
  restart)
        $0 stop
        $0 start
        RETVAL=$?
        ;;
  condrestart)
       [ -e /var/lock/subsys/dnspod-sr ] && $0 restart
       ;;
  status)
        status dnspod-sr
        RETVAL=$?
        ;;
  *)
        echo "Usage: $0 {start|stop|restart|condrestart|status}"
        exit 1
esac

exit $RETVAL
