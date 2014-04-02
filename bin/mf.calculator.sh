#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
#
#
echo "$*" | grep -q '^$' && {
	echoE "\nusage:\n   $(basename $0) 'some arithmetic operations'\n\nexample:\n   $(basename $0) '(2^32)*(1/2)'\n"
	exit 1
} || {
	echo "$*" | bc -l
}

