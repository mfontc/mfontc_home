#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

# ------------------------------------------------------------------------------
function permRepair() {
  projectBasePath="$1"

  if [[ ! -d "${projectBasePath}" ]]; then
    echoEr "El directorio «${projectBasePath}» no es válido."
    exit 1
  fi

  # Git.
  # [1] «./.git» (no recursivo).
  # [2] «./.git/*» (recursivo), excepto «./.git/.» y «./.git/objects».
  # [3] «./.git/objects» (recursivo, especial).
  gitBasePath="${projectBasePath}/.git"
  if [[ ! -d "${gitBasePath}" ]]; then
    echoEr "El directorio «${gitBasePath}» no existe. Es probable que el directorio no sea el de un proyecto."
    exit 1
  else
    # [1]
    chmod -c ug+rwX,o-rwx "${gitBasePath}"

    # [2]
    find "${gitBasePath}"/. -maxdepth 1 | \
      sed 's/\/\.\//\//g' | \
      sort | \
      grep -v "/.git/\.$\|/\.git/objects$" | \
      while read l ; do
        chmod -c -R ug+rwX,o-rwx "${l}"
      done

    # [3]
    find "${gitBasePath}/objects" -type d -print0 | xargs -0 chmod -c ug+rwX,o-rwx
    find "${gitBasePath}/objects" -type f -print0 | xargs -0 chmod -c ug+rX-w,o-rwx
  fi

  # Directorio actual (no recursivo).
  chmod -c ug+rwX,o-rwx "${projectBasePath}"

  # Ficheros y directorios dentro del directorio del proyecto (recursivo), excepto:
  find "${projectBasePath}"/. -maxdepth 1 | \
    sed 's/\/\.\//\//g' | \
    sort | \
    grep -v "^${projectBasePath}/\.$" | \
    grep -v "^${projectBasePath}/\.git$" | \
    grep -v "^${projectBasePath}/\.unison$" | \
    grep -v "^${projectBasePath}/node_modules$" | \
    grep -v "^${projectBasePath}/var$" | \
    while read l ; do
      chmod -c -R ug+rwX,o-rwx "${l}"
    done
}

# ------------------------------------------------------------------------------
echoCmd "$0 \"$1\""
permRepair "$1"
