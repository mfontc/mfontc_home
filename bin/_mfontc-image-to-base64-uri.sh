#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

image="$1"

if [[ ! -f "${image}" ]]; then
  echoEr "File not found!"
  exit 1
fi

mimetype -Mb "${image}" | grep -q -i "^image" || {
  echoEr "The file «${image}» is not an image!"
  exit 1
}

imageMimetype=`file -b --mime-type "${image}"`
imageEncoded=`base64 -w 0 "${image}"`
echo "data:$imageMimetype;base64,$imageEncoded"

