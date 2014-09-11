#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
# FUNCTIONS
#
_r() {
	pathToRemove="$1"
	echo_ "# [rm   ] $pathToRemove"
	[[ -d "$pathToRemove" ]] && rm -rfv "$pathToRemove"
	[[ -f "$pathToRemove" ]] && rm -fv  "$pathToRemove"
}

_rexp() {
	pathToRemove="$1"
	f="$2"
	echo_ "# [rm re] $pathToRemove ($f)"
	find "$pathToRemove" -type f -iname "$f" -delete
}

#
# MAIN
#
_r    "$HOME/.local/share/Trash"
_r    "$HOME/.cache/thumbnails"
_r    "$HOME/.adobe"
_r    "$HOME/.macromedia"
_r    "$HOME/.local/share/recently-used.xbel"
_r    "$HOME/.viminfo"
_r    "$HOME/.lesshst"
_r    "$HOME/.w3m/history"
_r    "$HOME/.cache/vlc"
_rexp "$HOME/.cache/upstart" "*.gz"

