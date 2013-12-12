#!/bin/bash

_f() {
    ext="$1"
    num=$( find . -maxdepth 1 -type f -name "*.${ext}" | wc -l )

    if [[ "$num" -eq "0" ]]; then
        return 1
    else
        echo ">>> Ficheros encontrados: $num"
        return 0
    fi
}


_f 'jpeg' && rename -v 's/.jpeg/.jpg/' *.jpeg
_f 'JPG'  && rename -v 's/.JPG/.jpg/' *.JPG
_f 'TIF'  && rename -v 's/.TIF/.tif/' *.TIF
_f 'PNG'  && rename -v 's/.PNG/.png/' *.PNG

rename -v 's/  / /g' *

_f 'tif' && for tif in *.tif; do
    imgTif="$tif"
    imgJpg="${tif%%.tif}_from_tif_.jpg"
    imgJpgF="${tif%%.tif}.jpg"
    convert "${imgTif}" "${imgJpg}" && rm -rf "${imgTif}" && mv "${imgJpg}" "${imgJpgF}"
done

_f 'png' && for png in *.png; do
    imgPng="$png"
    imgJpg="${png%%.png}_from_png_.jpg"
    imgJpgF="${png%%.png}.jpg"
    convert "${imgPng}" "${imgJpg}" && rm -rf "${imgPng}" && mv "${imgJpg}" "${imgJpgF}"
done

_f 'bmp' && for bmp in *.bmp; do
    imgBmp="$bmp"
    imgJpg="${bmp%%.bmp}_from_bmp_.jpg"
    imgJpgF="${bmp%%.bmp}.jpg"
    convert "${imgBmp}" "${imgJpg}" && rm -rf "${imgBmp}" && mv "${imgJpg}" "${imgJpgF}"
done

_f 'jpg' && jpegoptim --max=90 --strip-all --force --totals *.jpg

