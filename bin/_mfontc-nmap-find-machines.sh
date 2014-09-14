#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" ) && autoload -Uz mfontc-echoes && mfontc-echoes

#
# FUNCTIONS
#
print_nmap_line() {

	echo "$*" | grep -q "^Nmap scan report for" || return 1

	_line=$( echo "$*" | sed 's/^Nmap scan report for *//' )

	echo "${_line}" | \
		grep -q '^.*(.*)$' && {
			# Ex: devel (192.168.3.172)
			_name=$( echo "${_line}" | sed "s/\(.*\)  *(\(.*\))/\1/" )
			_ip=$(   echo "${_line}" | sed "s/\(.*\)  *(\(.*\))/\2/" )
		} || {
			# Ex: 192.168.3.172
			_name='-'
			_ip="${_line}"
		}

	[[ "${_ip}" == "${myIp}" ]] && you=":-)" || you=" "
	printf "%s#%s#%s\n" "${_ip}" "${you}" "${_name}"
}

#
# MAIN
#
sudo echo -n ''

which nmap &> /dev/null || {
	sudo apt-get update       || return 1
	sudo apt-get install nmap || return 1
}

myIpAndNetMask="$1"
if [[ -z "${myIpAndNetMask}" ]]; then
	myIpAndNetMask=$( ip addr | grep '^ *inet ' | grep -v '127.0.' | sed 's/^ *inet //;s/ .*$//' )
fi

myIp=$( echo "${myIpAndNetMask}" | sed 's/\/.*$//' )

echo_ "#"
echo_ "# Local IP discovery: ${myIpAndNetMask}"
echo_ "#"

sudo nmap -sn "$myIpAndNetMask" | \
	while read nmapLine; do
		print_nmap_line "$nmapLine"
	done | \
	sort -n | \
	column -t -s'#'


