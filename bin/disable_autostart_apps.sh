#!/bin/bash

# -----------------------------------------------------------------------------
# FUNCTIONS & VARS (lo primero, siempre)
#
echo_() { echo -e '\033[32m'"$*"'\033[0m'; }; echoE() { echo -e '\033[31m'"$*"'\033[0m' > /dev/stderr ; }; pause_() { echo -e -n '\033[33m'"--- PAUSE [press 'q' to break the execution of the script] "'\033[0m'; read -n 1 opt; case "$opt" in q|Q) echo; exit 1 ;; esac; }; yesOrNot_() { echo -e -n '\033[33m'"$* [Y/n] "'\033[0m' ; read -n 1 opt ; case "$opt" in n|N) echo ; return 1 ;; esac ; }; gotRoot() { [[ $UID -eq 0 ]] || { echoE "You are not root. Go home!"; exit 1; }; }; gotUtf8() { case none"$LANG$LC_ALL$LC_CTYPE" in *UTF-8*) ;; *) echoE "This script must be run in an UTF-8 locale"; exit 1 ;; esac; }; _now="$( date +%Y-%m-%d_%H-%M-%S )" || exit 1 ; _day="$( date +%Y-%m-%d )" || exit 1

gotRoot

# -----------------------------------------------------------------------------
#
#
disable_autostart() {
	_app="$*"

	autostartDir='/etc/xdg/autostart'
	autostartApp="${autostartDir}/${_app}"

	if [[ -f "${autostartApp}" ]]; then
		mv -v "${autostartApp}" "${autostartApp}.old"
	fi
}

for app in "zeitgeist-datahub.desktop" "onboard-autostart.desktop" "orca-autostart.desktop" "deja-dup-monitor.desktop" "update-notifier.desktop" "vino-server.desktop"; do
	disable_autostart "$app"
done

