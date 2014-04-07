#!/bin/bash
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

cccc="$1"
GC_copseg="$2"
_day="$( date +%Y-%m-%d )" || exit 1

# -----------------------------------------------------------------------------
# Detección del código de cliente
#
chkCcClientCod() {
    echo "${cccc}" | grep -q -i "[0-9]\{4\}\|[0-9]\{8\}" && {
        echo ">>> [INFO]        Código de cliente: '${cccc}'"
    } || {
        echo "### [ERROR]       No se ha pasado el código de cliente como parámetro, o no es correcto: '${cccc}'" > /dev/stderr
        exit 1
    }

    return 0
}

# -----------------------------------------------------------------------------
# copseg.zip TO tgz
#
copsegToTgz() {
    _GC_copseg="$1"
    _cccc="$2"

    dirExtractGescen="extract_${_cccc}"
    gescenTgz="gc_${_cccc}_${_day}.tgz"

    if [[ ! -f "${_GC_copseg}" ]]; then
        echo "### [ERROR]       No se ha encontrado el fichero con el GesCen '${_GC_copseg}'." > /dev/stderr
        exit 1
    fi

    if [[ -d "${dirExtractGescen}" ]]; then
        echo "### [ERROR]       No se puede descromprimir el gescen en el directorio existente '${dirExtractGescen}'." > /dev/stderr
        exit 1
    fi

    unzip -oCqq -d "${dirExtractGescen}" "${_GC_copseg}" alumnos.* profesor.* personal.* departa.* grupos.* horgrup.* asignat.* asigalum.* provin.* centro.* || {
        echo "### [ERROR]       No se ha podido extraer el fichero '${dirExtractGescen}'." > /dev/stderr
        exit 1
    }

    tar cvfz "${gescenTgz}" -C "${dirExtractGescen}/" . || {
        echo "### [ERROR]       No se ha podido comprimir los ficheros necesarios del GesCen en '${gescenTgz}'." > /dev/stderr
        exit 1
    }

    rm -rf "${dirExtractGescen}"

    return 0
}

# -----------------------------------------------------------------------------
# MAIN
#
chkCcClientCod
copsegToTgz "${GC_copseg}" "${cccc}"

