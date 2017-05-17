#!/bin/bash
# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

_now="`date +%Y%m%d_%H%M%S`"

CHK_xmllint() {
    which xmllint > /dev/null || {
        echo "### ERROR: No se ha encontrado el comando 'xmllint'. Se intentará instalar:"
        sudo apt-get install libxml2-utils
        which xmllint || {
            echo "### ERROR: No se ha encontrado el comando 'xmllint'."
            exit 1
        }
    }
}

# ------------------------------------------------------------------------------

_xmlFile=''
setXmlFile() {
    fileXML="$1"

    if [[ -f "${fileXML}" ]]; then
        _xmlFile="$(tempfile)"
        if file "${fileXML}" | grep -q 'gzip' ; then
            zcat "${fileXML}" > "${_xmlFile}"
        else
            cat  "${fileXML}" > "${_xmlFile}"
        fi
        return 0
    else
        echo "### ERROR: No se ha especificado como parámetro ningún fichero XML de Itaca"
        exit 1
    fi
}

delXmlFile() {
    if [[ -f "${_xmlFile}" ]]; then
        rm -f "${_xmlFile}"
    fi
}

# ------------------------------------------------------------------------------

_parsedXmlDir=''
setDirForParsedXml() {
    fileXML="$1"

    fileXML2="$( echo "$fileXML" | sed 's/[\. ]/_/g;s/[\/]//g;s/_gz$//;s/_xml$//' )"
    _parsedXmlDir="${fileXML2}_parsed_${_now}"

    mkdir -p "${_parsedXmlDir}"
}

# ------------------------------------------------------------------------------

extract_tag_from_xml_file() {
    tag="$1"

    # Creación del fichero XML parseado y reparado
    newXmlTagFile="${_parsedXmlDir}/${tag}.xml"
    echo -e "[${tag}]\t${newXmlTagFile}"
    cat "$_xmlFile" | grep -o "<$tag>.*</$tag>" | xmllint --format --noblanks --encode UTF-8 - > "${newXmlTagFile}"

    return 0
}

# ------------------------------------------------------------------------------

touch_tag_from_xml_file() {
    tag="$1"

    # Toque al fichero XML (si no existe, se crea!)
    newXmlTagFile="${_parsedXmlDir}/${tag}.xml"
    touch "${newXmlTagFile}"

    return 0
}

# ------------------------------------------------------------------------------

get_tags_from_xml_file() {
    cat "${_xmlFile}" | xmllint --format --noblanks --encode UTF-8 - | grep " *<[^ /]*>" | sed "s/ *<//" | sed "s/>//" | sort -u
}

# ------------------------------------------------------------------------------

CHK_xmllint

file="$1"
setXmlFile "$file"
setDirForParsedXml "$file"

for tag in $(get_tags_from_xml_file ); do
    extract_tag_from_xml_file "${tag}"
done

delXmlFile

#
exit 0

#
for tag in \
    actividades_complementarias \
    alumnos \
    aulas \
    categorias \
    compensatorias \
    contenidos \
    contenidos_alumno \
    cursos \
    cursos_grupo \
    denominaciones \
    docentes \
    empresas_proveedoras \
    ensenanzas \
    evaluaciones \
    faltas_alumno \
    faltas_docentes \
    familiares \
    funciones_no_docente \
    grupos \
    grupos_actividad \
    horarios_grupo \
    horarios_ocupaciones \
    idiomas \
    justificaciones \
    lenguajes_vehiculares \
    lineas \
    localidades \
    medidas_educativas \
    medidas_neses \
    modalidades_asistencia \
    motivos_sustitucion \
    municipios \
    neses \
    no_docentes \
    ocupaciones \
    organismos \
    paises \
    parentescos \
    participantes_actividad \
    planificaciones_actividad \
    plantillas_horario \
    provincias \
    recursos_neses \
    recursos_personales \
    responsables_actividad \
    sesiones_horario \
    tipos_actividad_complementaria \
    tipos_compensatorias \
    tipos_comportamiento \
    tipos_docente \
    tipos_documentos \
    tipos_nese \
    tipos_no_docente \
    tipos_nota \
    tipos_vias \
    turnos
do
    touch_tag_from_xml_file "${tag}"
done

# Old tags
#    actividades_complementarias \
#    alumnos \
#    aulas \
#    categorias \
#    compensatorias \
#    contenidos \
#    contenidos_alumno \
#    cursos \
#    cursos_grupo \
#    denominaciones \
#    docentes \
#    empresas_proveedoras \
#    ensenanzas \
#    evaluaciones \
#    familiares \
#    funciones_no_docente \
#    grupos \
#    horarios_grupo \
#    idiomas \
#    justificaciones \
#    lenguajes_vehiculares \
#    lineas \
#    medidas_educativas \
#    medidas_neses \
#    modalidades_asistencia \
#    motivos_sustitucion \
#    neses \
#    no_docentes \
#    ocupaciones \
#    organismos \
#    parentescos \
#    plantillas_horario \
#    recursos_neses \
#    recursos_personales \
#    sesiones_horario \
#    tipos_actividad_complementaria \
#    tipos_compensatorias \
#    tipos_comportamiento \
#    tipos_docente \
#    tipos_documentos \
#    tipos_nese \
#    tipos_no_docente \
#    tipos_nota \
#    tipos_vias \
#    turnos \
#    localidades \
#    municipios \
#    provincias \
#    paises

