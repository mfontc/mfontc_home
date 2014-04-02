#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" )
autoload -Uz mfontcEchoes
mfontcEchoes

#
#
#
which convert jpegoptim jhead &> /dev/null || {
	echoE "There are some missed packages in the system!"
	sudo apt-get update || exit 1
	sudo apt-get install imagemagick jpegoptim jhead || exit 1
}

#
#
#
checkMaxSize() {
	_maxSize=$( echo "$1" | grep -o "^[0-9]*$" )

	if [[ ( $_maxSize -lt 32 ) || ( $_maxSize -gt 2048 ) ]]; then
		echoE "\nEl tamaño máximo debe ser un número entre 32 y 2048.\n"
		return 1
	fi

	return 0
}

checkJpgQuality() {
	_jpgQlty=$( echo "$1" | grep -o "^[0-9]*$" )

	if [[ ( $_jpgQlty -lt 50 ) || ( $_jpgQlty -gt 99 ) ]]; then
		echoE "\nLa calidad jpg debe ser un número entre 50 y 90.\n"
		return 1
	fi

	return 0
}

findImages() {
	ext="$1"

	# Encuentra todos los ficheros con la extensión $ext
	find . -maxdepth 1 -type f -name "*.${ext}" | \
		while read _image; do
			# Pero solamente mostramos los que sabemos que son imágenes
			mimetype -Mb "${_image}" | grep -q -i "^image" && echo "${_image}"
		done
}

#
#
#
_cmd=$(basename "$0")

usage () {
	cat << EOF
USAGE:
   $_cmd <OPTIONS>

OPTIONS:
   -s <max_size>    Tamaño máximo en pixels que tendrán las imágenes.
   -q <quality>     Calidad del jpg resultante.
   -h               Esta ayuda.

EXAMPLE:
   $_cmd -s 640 -q 75

EOF
}

while getopts ":hs:q:" opt ; do
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
		s)
			maxSize="$OPTARG"
			;;
		q)
			jpgQlty="$OPTARG"
			;;
	esac
done

# Comprobación del tamaño máximo y calidad de los jpg
checkMaxSize "$maxSize" || {
	usage
	exit 1
}

checkJpgQuality "$jpgQlty" || {
	usage
	exit 1
}

#
# MAIN
#
dir="z_resized_images_to_max_${maxSize}x${maxSize}"

findImages 'jpg' | while read imgJpg ; do
	echo_ "> $imgJpg"

	mkdir -p "${dir}" || exit 1

	imgJpgFinal="./${dir}/$( echo ${imgJpg} | sed 's/^\.\///' )"

	convert "${imgJpg}" -quality "${jpgQlty}" -resize "$maxSize"x"$maxSize" "${imgJpgFinal}" || exit 1
	echo "  ${imgJpgFinal} converted to max size ${maxSize}x${maxSize}"

	jhead -dt -purejpg "${imgJpgFinal}" || exit 1
	echo "  ${imgJpgFinal} optimized"

	echo
done

