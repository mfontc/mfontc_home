#!/bin/zsh
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

fpath=( ~/.mfontc_home/oh-my-zsh/zfuncs "${fpath[@]}" ) && autoload -Uz mfontc-echoes && mfontc-echoes

#
#
#
which convert jpegoptim jhead &> /dev/null || {
	echoE "There are some missed packages in the system!"
	sudo apt-get update || exit 1
	sudo apt-get install imagemagick jpegoptim jhead || exit 1
}

#
# FUNCTIONS
#
renameExtension() {
	ext1="$1"
	ext2="$2"

	echo_ "# Ext. conversion: «*.${ext1}» to «*.${ext2}»"

	num=$(find . -maxdepth 1 -type f -iname "*.${ext1}" | wc -l)

	if [[ $num -eq 0 ]]; then
		return 1
	else
		find . -maxdepth 1 -type f -iname "*.${ext1}" | \
			while read img; do
				rename -v 's/\.'${ext1}'$/.'${ext2}'/i' "${img}"
			done
		return 0
	fi
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

convertToFormat() {
	_img="$1"
	_to="$2"

	# El fichero debe existir
	if [[ ! -f "${_img}" ]]; then
		echoE "File «${_img}» not found!"
		return 1
	fi

	# Extensión del fichero original.
	_from=$( echo "$_img" | sed "s/^.*\.//" )

	# No pueden ser la misma extensión
	if [[ "${_from}" == "${_to}" ]]; then
		echoE "Fila «${_img}» already has «${_to}» extension!"
		return 1
	fi

	# Nombre del fichero sin la extensión.
	_preffix=$( echo "$_img" | sed "s/\.${_from}$//" )

	# Nombre del fichero temporal.
	_imgTmp=$( echo "${_preffix}_from_${ext}_.jpg" )

	# Nombre del fichero final.
	_imgFinal=$( echo "${_preffix}.${_to}" )

	# Vamos a usar un ejemplo de fichero original y extensión final para explicar el código.
	# _img:      "1234.tif"
	# _to:       "jpg"
	# _from:     "tif"
	# _preffix:  "1234"
	# _imgTmp:   "1234_from_tif_.jpg"
	# _imgFinal: "1234.jpg"

	# MAIN
	convert "${_img}" "${_imgTmp}" && rm -rf "${_img}" && mv "${_imgTmp}" "${_imgFinal}"
}

optimizeJpg() {
	_imgJpg="$1"

	# El fichero debe existir
	if [[ ! -f "${_imgJpg}" ]]; then
		echoE "File «${_imgJpg}» not found!"
		return 1
	fi

	jpegoptim --max=90 --strip-all --force "${_imgJpg}"
}



#
# MAIN
#

#
# 1. Modificaciones de las extensiones de los ficheros
#
renameExtension 'JPEG' 'jpg'
renameExtension  'JPG' 'jpg'
renameExtension  'TIF' 'tif'
renameExtension  'PNG' 'png'
renameExtension  'BMP' 'bmp'

#
# 2. Conversión de ficheros a jpg
#
echo_ "\n# File conversion: «*.tif» to «jpg»"
findImages 'tif' | while read imgTif ; do
	convertToFormat "${imgTif}" 'jpg'
done

echo_ "# File conversion: «*.png» to «jpg»"
findImages 'png' | while read imgPng ; do
	convertToFormat "${imgPng}" 'jpg'
done

echo_ "# File conversion: «*.bmp» to «jpg»"
findImages 'bmp' | while read imgBmp ; do
	convertToFormat "${imgBmp}" 'jpg'
done

#
# 3. Optimización de todos los jpg
#
echo_ "\n# Optimizing «*.jpg» images"
findImages 'jpg' | while read imgJpg ; do
	optimizeJpg "${imgJpg}"
done

