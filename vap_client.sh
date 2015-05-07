#!/bin/sh

usage() {
	echo "Usage: $0 [del|add] num"
	exit 1;
}

if [ "X$2" = "X" ]; then
	usage
fi

del_vap() {
	#killall iperf
	killall wpa_supplicant
	for i in `seq 0 $1`
	do
		iw dev wtap$i del
		rm /etc/wpa_sup/wpa_supplicant_wtap$i.conf
	done
	exit;
}

add_vap() {
	for i in `seq 0 $1`
	do
		mod=`expr $i % 8`
		iw phy phy1 interface add wtap$i type station
		ip link set dev wtap$i address AA:BB:CC:DD:FF:$i
		ip addr add 10.0.0.`expr $i + 9`/24 dev wtap$i
		ip link set dev wtap$i up
		sed -e "s/XX/0$mod/g" /etc/wpa_sup/wpa_supplicant_template.conf > /etc/wpa_sup/wpa_supplicant_wtap$i.conf
		wpa_supplicant -d -c /etc/wpa_sup/wpa_supplicant_wtap$i.conf -i wtap$i -B
		#ping -I wtap$i 10.0.0.`expr $mod + 1` &
		#ping -I wtap$i 10.0.0.1 &
		#iperf -c 10.0.0.1 -B 10.0.0.`expr $i + 9` -t 100 &
		#sleep 4
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
