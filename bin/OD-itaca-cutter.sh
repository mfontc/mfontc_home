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

xml_file_exists() {
    fileXML="$1"

    if [[ -f "${fileXML}" ]]; then
        return 0
    else
        echo "### ERROR: No se ha especificado como parámetro ningún fichero XML de Itaca"
        exit 1
    fi
}

extract_tag_from_xml_file() {
    file="$1"
    tag="$2"

    # Creación del directorio
    dir="xml_repared_${_now}"
    mkdir -p "${dir}"

    # Creación del fichero XML parseado y reparado
    new_file="${dir}/${tag}.xml"
    echo ">>> $file > $tag"
    cat "$file" | grep -o "<$tag>.*</$tag>" | xmllint --format --noblanks --encode UTF-8 - > "${new_file}"

    return 0
}

touch_tag_from_xml_file() {
    tag="$1"

    # Creación del directorio
    dir="xml_repared_${_now}"
    mkdir -p "${dir}"

    # Toque al fichero XML (si no existe, se crea!)
    new_file="${dir}/${tag}.xml"
    touch "${new_file}"

    return 0
}

get_tags_from_xml_file() {
    file="$1"

    cat "${file}" | xmllint --format --noblanks --encode UTF-8 - | grep " *<[^ /]*>" | sed "s/ *<//" | sed "s/>//" | sort -u
}

file="$1"

CHK_xmllint

xml_file_exists "$file"

for tag in $(get_tags_from_xml_file "${file}" ); do
    extract_tag_from_xml_file "${file}" "${tag}"
done

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

