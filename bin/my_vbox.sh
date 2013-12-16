#!/bin/bash

HERE="$PWD"
trap "cd \"${HERE}\" ; " EXIT INT TERM

function echo_          { echo -e '\033[32m'"$*"'\033[0m' ; }
function echoN_         { echo -e -n '\033[32m'"$*"'\033[0m' ; }
function echoE          { echo -e '\033[31m'"$*"'\033[0m' > /dev/stderr ; }
function echoCOL        { cols=$(( $(tput cols) - 10 )); printf "%-${cols}s" "$*" ; }
function echoSQL        { echo -e '\033[34m'"--- SQL\n$*"'\033[0m' ; }
function echoComm       { echo -e '\033[34m'"--- command: $*"'\033[0m' ; }
function cont_          { for i in $(seq 1 3) ; do echo -e -n '\033[33m'"."'\033[0m' ; sleep 0.1 ; done ; echo -e "\n\n\n" ; }
function pause_         { echo -e -n '\033[33m'"--- PAUSE [ Press a key to continue; 'q' breaks the execution ] "'\033[0m' ; read -n 1 opt ; case "$opt" in q|Q) echo ; exit 1 ;; esac ; }
function siono_         { echo -e -n '\033[33m'"$* [S/n] "'\033[0m' ; read -n 1 opt ; case "$opt" in n|N) echo ; return 1 ;; esac ; }

function got_root       { [[ $USER == "root" ]] || { echoE "Lo siento, debes ser root"; exit 1; }; }
function got_utf8       { echo_ ">>> UTF-8"; case none"$LANG$LC_ALL$LC_CTYPE" in *UTF-8*) ;; *) echoE "This script must be run in a UTF-8 locale"; exit 1 ;; esac; cont_ ; }
function which_PROGRAMS { echo_ ">>> Programas necesarios para poder ejecutarse el script"; PROGRAMS="mysql mysqldump $*"; echoComm "which ${PROGRAMS}"; which ${PROGRAMS} || { echoE "    Asegúrate de tener todas estas aplicaciones instaladas y accesibles: ${PROGRAMS}"; exit 1; } ; }

_now="$(date +%Y%m%d-%H%M%S)" || exit 1

# /////////////////////////////////////////////////////////////////////////////
#
# FUNCTIONS
#
# /////////////////////////////////////////////////////////////////////////////

function list_vms
{
	VBoxManage list vms | sed 's/" {.*$//;s/"//g' | sort -u
}

function list_running_vms
{
	VBoxManage list runningvms | sed 's/" {.*$//;s/"//g' | sort -u
}

function is_a_valid_vm
{
	_vm="$1"
	list_vms | grep -q "${_vm}" || {
		echoE "# ERROR: «${_vm}» no es una máquina virtual válida"
		exit 1
	}
}

function vm_is_active
{
	_vm="$1"
	is_a_valid_vm "${_vm}"
	VBoxManage list runningvms | grep -q "^\"${_vm}"
}

function start_vm
{
	_vm="$1"
	echo_ "# Starting VM «${_vm}»"
	vm_is_active "${_vm}" && {
		echo "# La máquina virtual «${_vm}» ya estaba en marcha."
		return 0
	} || {
		nohup VBoxHeadless -startvm "${_vm}" &> /dev/null &
		echo "# Se está arrancando la máquina virtual «${_vm}»"
		return 0
	}
}

function stop_vm
{
	_vm="$1"
	echo_ "# Stoping VM «${_vm}»"
	vm_is_active "${_vm}" && {
		VBoxManage controlvm "${_vm}" poweroff
		return 0
	} || {
		echo "# La máquina virtual «${_vm}» ya estaba apagada."
		return 0
	}
}

function start_stop_vm
{
	_vm="$1"
	vm_is_active "${_vm}" && {
		stop_vm "${_vm}"
		return 0
	} || {
		start_vm "${_vm}"
		return 0
	}
}

function menu_change_vm_state
{
	vm_i=1
	vm_array=(" " $(list_vms))
	for vm in ${vm_array[@]:1:10} ; do
		vm_running=$(vm_is_active "${vm_array[$vm_i]}" && echo "ON" || echo "OFF" )
		printf "%4s: [ %-3s ] %s\n" "${vm_i}" "${vm_running}" "${vm}"
		vm_i=$((vm_i + 1))
	done

	#
	echo -e -n "\nCambia el estado de la máquina virtual número: "
	read vm_opt

	# Si la selección no es un número, es 0 o es un número mayor que el número
	# de VMs (recuerda restar 1 porque la posición 0 la hemos saltado para que
	# los índices empiecen por 1), salimos.
	echo "$vm_opt" | grep -q "^[0-9][0-9]*$" || {
		echoE "# ERROR: Opción incorrecta"
		exit 1
	}

	if [[ $vm_opt -lt 1 ]] ; then
		echoE "# ERROR: Opción incorrecta"
		exit 1
	fi

	if [[ $vm_opt -ge ${#vm_array[@]} ]] ; then
		echoE "# ERROR: Opción incorrecta"
		exit 1
	fi

	start_stop_vm "${vm_array[$vm_opt]}"
}



# /////////////////////////////////////////////////////////////////////////////
#
# MAIN
#
# /////////////////////////////////////////////////////////////////////////////

function usage
{
cat << EOF
USAGE:
   $0 <OPTIONS>

OPTIONS:
   -l           Muestra las máquinas virtuales del sistema.
   -r           Muestra las máquinas virtuales del sistema arrancadas.
   -s <VM>      Arranca la máquina virtual "VM".
   -k <VM>      Apaga   la máquina virtual "VM".
   -h           Esta ayuda.

EOF
}

while getopts ":hlrs:k:" opt ; do
	case $opt in
		:)
			echoE "# ERROR: Option -$OPTARG requires an argument."
			exit 1
			;;
		\?)
			echoE "# ERROR: Invalid option: -$OPTARG"
			usage
			exit 1
			;;
		h)
			usage
			exit 1
			;;
		l)
			echo_ "# Listado de máquinas virtuales"
			list_vms
			exit 0
			;;
		r)
			echo_ "# Listado de máquinas virtuales en marcha"
			list_running_vms
			exit 0
			;;
		s)
			vm="$OPTARG"
			start_vm "${vm}"
			exit 0
			;;
		k)
			vm="$OPTARG"
			stop_vm  "${vm}"
			exit 0
			;;
	esac
done

menu_change_vm_state

