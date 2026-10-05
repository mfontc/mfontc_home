#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

sudo echo -n ''

which nmap &> /dev/null || {
  sudo apt-get update       || exit 1
  sudo apt-get install nmap || exit 1
}

dst="$1"
if [[ -z "${dst}" ]]; then
  echoD "usage:"
  echoD "   $(basename $0) destination.to.scan [scanning_method]"
  echoD
  echoD "examples:"
  echoD "   $(basename $0) 192.168.0.1 2"
  echoD "   $(basename $0) www.url.com 1"
  echoD
  echoD "options:"
  echoD "   [none]: Default scan"
  echoD "   1:      Quick and detectable scan"
  echoD "   2:      Aggressive scan"
  echoD
  exit 1
fi

echo

opt="$2"
case $opt in
  1) echoS "# Quick and detectable scan to $dst"; sudo nmap -v -T5 -O -sS     -sV -p- "${dst}" ;;
  2) echoS "# Aggressive scan to $dst";           sudo nmap -v -T2 -O -sS -sU -sV -P0 "${dst}" ;;
  *) echoS "# Default scan to $dst";              sudo nmap -v     -O -sS -sU -sV -P0 "${dst}" ;;
esac

