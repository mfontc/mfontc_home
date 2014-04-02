#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
#
#
which pwgen &> /dev/null || {
	echoE "There are some missed packages in the system!"
	sudo apt-get update || exit 1
	sudo apt-get install pwgen || exit 1
}

#
# MAIN
#
pwgen --capitalize --numerals --secure --ambiguous 16 100

