#!/bin/bash

which nmap &> /dev/null || {
	sudo apt-get install nmap || return 1
}

ip_and_netmask="$1"
if [[ -z "${ip_and_netmask}" ]]; then
	ip_and_netmask=$( ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | grep -v '^25' | head -n 1 )
	ip_and_netmask="${ip_and_netmask}/24"
fi

echo ">"
echo "> Local IP discovery"
echo "> Using this IP/NetMask: ${ip_and_netmask}"
echo ">"

sudo nmap -sn $ip_and_netmask | \
	grep -v "^Host is up" | \
	grep "^Nmap scan report for" | \
	sed "s/^Nmap scan report for *//;s/\(.*\)  *(\(.*\))/\2\t\1/"

