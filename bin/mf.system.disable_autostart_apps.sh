#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
# FUNCTIONS
#
gotRoot() {
	[[ $UID -eq 0 ]] || {
		echoE "You are not root. Go home!"
		exit 1
	}
}

disable_autostart() {
	_app="$*"

	autostartDir='/etc/xdg/autostart'
	autostartApp="${autostartDir}/${_app}"

	if [[ -f "${autostartApp}" ]]; then
		mv -v "${autostartApp}" "${autostartApp}.old"
		printf "%50s dissabled!\n" "${autostartApp}"
		return 0
	else
		printf "%50s not found or already dissabled!\n" "${autostartApp}"
		return 1
	fi
}

#
# MAIN
#
gotRoot

for app in "zeitgeist-datahub.desktop" "onboard-autostart.desktop" "orca-autostart.desktop" "deja-dup-monitor.desktop" "update-notifier.desktop" "vino-server.desktop"; do
	disable_autostart "$app"
done

