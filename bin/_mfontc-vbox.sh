#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" ) && autoload -Uz mfontc-echoes && mfontc-echoes

#
# FUNCTIONS
#

list_vms () {
	VBoxManage list vms | sed 's/" {.*$//;s/"//g' | sort -u
}

list_running_vms () {
	VBoxManage list runningvms | sed 's/" {.*$//;s/"//g' | sort -u
}

is_a_valid_vm () {
	_vm="$1"
	list_vms | grep -q "${_vm}" || {
		echoE "# ERROR: «${_vm}» no es una máquina virtual válida"
		exit 1
	}
}

vm_is_active () {
	_vm="$1"
	is_a_valid_vm "${_vm}"
	VBoxManage list runningvms | grep -q "^\"${_vm}\""
}

start_vm () {
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

stop_vm () {
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

start_stop_vm () {
	_vm="$1"
	vm_is_active "${_vm}" && {
		stop_vm "${_vm}"
		return 0
	} || {
		start_vm "${_vm}"
		return 0
	}
}

menu_change_vm_state () {
	vm_i=1
	#bash: vm_array=(" " $(list_vms))
	#bash: for vm in ${vm_array[@]:1:10} ; do
	vm_array=($(list_vms))
	for vm in ${vm_array[@]} ; do
		vm_running=$(vm_is_active "${vm_array[$vm_i]}" && echo "ON" || echo "OFF" )
		printf "%4s: [ %-3s ] %s\n" "${vm_i}" "${vm_running}" "${vm}"
		vm_i=$((vm_i + 1))
	done

	#
	echoQ "\nCambia el estado de la máquina virtual número: "
	read vm_opt

	# Si la selección no es un número, es 0 o es un número mayor que el número
	# de VMs (recuerda restar 1 porque la posición 0 la hemos saltado para que
	# los índices empiecen por 1), salimos.
	echo "$vm_opt" | grep -q "^[0-9][0-9]*$" || {
		echoE "\n# ERROR: Opción incorrecta\n"
		exit 1
	}

	if [[ $vm_opt -lt 1 ]] ; then
		echoE "\n# ERROR: Opción incorrecta\n"
		exit 1
	fi

	if [[ $vm_opt -ge ${#vm_array[@]} ]] ; then
		echoE "\n# ERROR: Opción incorrecta\n"
		exit 1
	fi

	start_stop_vm "${vm_array[$vm_opt]}"
}

usage () {
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
			echoE "\n# ERROR: Option -$OPTARG requires an argument.\n"
			exit 1
			;;
		\?)
			echoE "\n# ERROR: Invalid option: -$OPTARG\n"
			usage
			exit 1
			;;
		h)
			usage
			exit 1
			;;
		l)
			echo_ "\n# Listado de máquinas virtuales\n"
			list_vms | cat -n -
			echo
			exit 0
			;;
		r)
			echo_ "\n# Listado de máquinas virtuales en marcha\n"
			list_running_vms
			echo
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

#
# MAIN
#

menu_change_vm_state

