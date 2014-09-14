#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" ) && autoload -Uz mfontc-echoes && mfontc-echoes

#
#
#
sudo echo -n ''

which nmap &> /dev/null || {
	sudo apt-get update       || exit 1
	sudo apt-get install nmap || exit 1
}

dst="$1"
if [[ -z "${dst}" ]]; then
	echoE <<<EOF
ew
EOF
	echoE "usage:"
	echoE "   $(basename $0) destination.to.scan [scanning_method]"
	echoE
	echoE "examples:"
	echoE "   $(basename $0) 192.168.0.1 2"
	echoE "   $(basename $0) www.url.com 1"
	echoE
	echoE "options:"
	echoE "   [none]: Default scan"
	echoE "   1:      Quick and detectable scan"
	echoE "   2:      Aggressive scan"
	echoE
	exit 1
fi

echo

opt="$2"
case $opt in
	1) echo_ "# Quick and detectable scan to $dst"; sudo nmap -v -T5 -O -sS     -sV -p- "${dst}" ;;
	2) echo_ "# Aggressive scan to $dst";           sudo nmap -v -T2 -O -sS -sU -sV -P0 "${dst}" ;;
	*) echo_ "# Default scan to $dst";              sudo nmap -v     -O -sS -sU -sV -P0 "${dst}" ;;
esac

