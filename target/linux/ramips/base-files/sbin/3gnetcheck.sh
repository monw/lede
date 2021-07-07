#!/bin/sh
#/sbin/3gnetcheck.sh
#  */3 * * * *       /sbin/3gnetcheck.sh

proto=`uci get network.ppp0.proto`
if [ "${proto}" != "3g" ]; then
        exit 0
else
    usbctrl.sh on
fi

if [ -f /etc/config/3gpinghost ]; then
        host=`tail -n 1 /etc/config/3gpinghost`
else
        host=www.baidu.com
        echo $host >/etc/config/3gpinghost
fi

CHECKTTYUSB1=`ls -l /dev/ttyUSB1 | wc -l ` 2>/dev/null
if [ "${CHECKTTYUSB1}" != "0" ]; then
    CHECKNET=`cat /tmp/rp.log | wc -l` 2>/dev/null
    if [ $CHECKNET -gt 1  ]; then
    echo -e "at+cfun=1,1\r\n" > /dev/ttyUSB1 &
    echo "  /sbin/3gnetcheck.sh LOG: Reset 3G mode reboot!!!" >/dev/ttyS0
    sleep 2
    rm -rf /tmp/rp.log
    sleep 20
    /etc/init.d/network restart
    exit 0
    fi
    PING=`ping $host -c 3 | grep loss | awk '{print $7}'` 2>/dev/null
    if [ "${PING}" == "100%" ]; then
    echo "1" >> /tmp/rp.log
    echo " /sbin/3gnetcheck.sh ERROR:: ping $host timeout !!" >/dev/ttyS0
    elif [ "${PING}" == "" ]; then
    echo "1" >> /tmp/rp.log
    echo " /sbin/3gnetcheck.sh ERROR:: ping: bad address '$host' !" >/dev/ttyS0
    else
    rm -rf /tmp/rp.log
    echo " the network is ok " > /dev/ttyS0 &
    fi
    exit 0
else
    rm -rf /tmp/rp.log
fi	
