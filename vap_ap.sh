#!/bin/sh

usage(){
	echo "Usage: $0 [del|add] num"
	exit 1;
}

if [ "X$2" = "X" ]; then
	usage
fi

del_vap() {
	killall hostapd
	for i in `seq 0 $1`
	do
		iw dev wtap$i del
		rm /etc/hostapd/hostapd_wtap$i.conf
	done
	exit;
}

add_vap() {
	for i in `seq 0 $1`
	do
		iw phy phy1 interface add wtap$i type __ap
		ip link set dev wtap$i address AA:BB:CC:DD:EE:$i
		#ip addr add 10.0.$i.1/24 dev wtap$i
		ip addr add 10.0.0.`expr $i + 1`/24 dev wtap$i
		ip link set dev wtap$i up
		sed -e "s/wtapX/wtap$i/g" /etc/hostapd/hostapd_template.conf > /etc/hostapd/hostapd_wtap$i.conf
		hostapd /etc/hostapd/hostapd_wtap$i.conf -B
	done
	exit;
}

if [ $1 == "del" ]; then
	if expr "$2" : '[0-9]' > /dev/null ; then
		del_vap $2
	else 
		usage
	fi
elif [ $1 == "add" ]; then
	if expr "$2" : '[0-9]' > /dev/null ; then
		add_vap $2
	else 
		usage
	fi
else 
	usage	
fi
