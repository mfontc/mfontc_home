#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
#
#
hostsPath='/etc/hosts'

echo_ "> You are going to edit «${hostsPath}»"

if [[ $UID -ne 0 ]]; then
	sudo echo -n ''
fi

sudo vim "${hostsPath}"

