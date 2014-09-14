#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" ) && autoload -Uz mfontc-echoes && mfontc-echoes

#
#
#
echo "$1" | grep -q '^$' && {
	echoE "\nusage:\n   $(basename $0) '/path/to/command_to_analyze'\n\nexample:\n   $(basename $0) '/bin/cat'\n"
	exit 1
} || {
	objdump -d "$1" | less
}

