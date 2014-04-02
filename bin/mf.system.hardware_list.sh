#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
#
#
sudo echo -n ''

for dmitype in bios system baseboard chassis processor memory cache connector slot; do
	echo_ "\n# ------------------------------------------------------------------------------\n# dmidecode --type $dmitype\n# ------------------------------------------------------------------------------"
	sudo dmidecode --type $dmitype
done

