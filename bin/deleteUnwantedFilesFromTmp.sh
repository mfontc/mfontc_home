#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

# ------------------------------------------------------------------------------
if [[ "$(whoami)" != "root" ]]; then
  echoEr "Lo siento, debes ser root"
  exit 1
fi

# ------------------------------------------------------------------------------
isOpenedByAnyProcess() {
  lsof "$*" >/dev/null 2>&1
}

getHumanSize() {
  _f="$*"
  _s="$(du -s -BM "${_f}" | sed 's/\t.*$//')"
  printf "%5s  %s" "${_s}" "${_f}"
}

printCurrentTmpSize() {
  echoIn "Tamaño actual del directorio «/tmp»: $(du -s -BM "/tmp" | sed 's/\t.*$//')"
}

# Ficheros de Apache2 o ficheros creados con «tempfile» y que no han sido eliminados.
deleteUnwantedFilesFromTmp() {
  (
    find /tmp -type f -group www-data -mtime +30
    find /tmp -type f -iname 'file*' -mtime +30
  ) | while read f; do
    if isOpenedByAnyProcess "${f}" ; then
      echoD "[!!!] $(getHumanSize "${f}")"
    else
      echo "[del] $(getHumanSize "${f}")"
      if [[ -f "${f}" ]] ; then
        rm -f "${f}"
      fi
    fi
  done
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
printCurrentTmpSize
deleteUnwantedFilesFromTmp
printCurrentTmpSize
