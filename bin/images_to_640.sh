#!/bin/bash

which convert jhead &> /dev/null || {
    echo "# Programas usados: convert jhead" > /dev/stderr
    echo "# Paquetes donde encontrarlos: imagemagick jhead" > /dev/stderr
    exit 1
}

tam=640
qua=75
dir="${tam}x${tam}"

mkdir -p "${dir}" || exit 1

for img in *.jpg; do
    echo ">>> ${img}"

    [[ -f "${img}" ]] || exit 1

    img_res="${dir}/${img}"
    convert "${img}" -quality $qua -resize "$tam"x"$tam" "${img_res}" || exit 1
    jhead -dt -purejpg "${img_res}" || exit 1
done

