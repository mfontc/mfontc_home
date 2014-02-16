#!/bin/bash

which nmap &> /dev/null || {
	sudo apt-get install nmap || return 1
}

dst="$1"
if [[ -z "${dst}" ]]; then
	echo "### ERROR: Unknown destination" > /dev/stderr
	exit 1
fi

echo -e "> Scanning: $dst"
opt="$2"
case $opt in
	1)	echo "> Quick and detectable scan";     sudo nmap -v -T5 -O -sS     -sV -p- $dst ;;
	2)	echo "> Aggressive scan";               sudo nmap -v -T2 -O -sS -sU -sV -P0 $dst ;;
	*)	echo "> Default scan";                  sudo nmap -v     -O -sS -sU -sV -P0 $dst ;;
esac

