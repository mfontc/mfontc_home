#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" ) && autoload -Uz mfontc-echoes && mfontc-echoes

#
#
#
image="$1"

if [[ ! -f "${image}" ]]; then
	echoE "File not found!"
	exit 1
fi

mimetype -Mb "${image}" | grep -q -i "^image" || {
	echoE "The file «${image}» is not an image!"
	exit 1
}

imageMimetype=`file -b --mime-type "${image}"`
imageEncoded=`base64 -w 0 "${image}"`
echo "data:$imageMimetype;base64,$imageEncoded"

