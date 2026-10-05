#!/usr/bin/env bash
# vim: ft=bash ts=2 sw=2 sts=2 noexpandtab
# WARNING: No se debe cambiar el tipo shell a «zsh» puesto que podría dar problemas en la primera instalación.
# WARNING: Esto implica no poder usar las funciones tipo «echo...»

# ------------------------------------------------------------------------------
etcDefaultZshHostnameFile="/etc/default/zsh_hostname"
localZshHostnameFile=~/.mfontc_home/oh-my-zsh/.zsh_hostname

_helpUpdate() {
  # The command «omz» can only be called directly from the prompt, so
  cat <<EOF

# Execute this command to reload the new prompt:
  omz reload

EOF
}

# ------------------------------------------------------------------------------
# Main
# ------------------------------------------------------------------------------
if [[ "$(whoami)" == "root" ]]; then
  # Si eres «root», permitimos la edición del fichero global
  sudo touch "${etcDefaultZshHostnameFile}"
  if [[ ! -s "${etcDefaultZshHostnameFile}" ]]; then
    echo "_CHANGE_THIS_DEFAULT_SERVER_NAME_" > "${etcDefaultZshHostnameFile}"
  fi
  sudo chown root:root "${etcDefaultZshHostnameFile}"
  sudo chmod 664 "${etcDefaultZshHostnameFile}"
  sudo vim "${etcDefaultZshHostnameFile}"
  sudo sed -i 's/^  *//;s/  *$//;s/^─ *//;s/ *─$//;s/^- *//;s/ *-$//;s/  */ /g' "${etcDefaultZshHostnameFile}"
fi

if [[ -s "${etcDefaultZshHostnameFile}" ]]; then
  # Repair symbols
  # Si el fichero global y el nuestro difieren, se actualiza el nuestro
  if [[ ! -f "${localZshHostnameFile}" ]]; then
    cat "${etcDefaultZshHostnameFile}" >"${localZshHostnameFile}"
    _helpUpdate
  elif ! diff -q "${etcDefaultZshHostnameFile}" "${localZshHostnameFile}" >/dev/null; then
    echo "[ WARNING ] Old prompt hostname: \"$(cat "${localZshHostnameFile}")\""
    echo "[ WARNING ] New prompt hostname: \"$(cat "${etcDefaultZshHostnameFile}")\""
    cat "${etcDefaultZshHostnameFile}" >"${localZshHostnameFile}"
    _helpUpdate
  fi
  sed -i 's/^  *//;s/  *$//;s/^─ *//;s/ *─$//;s/^- *//;s/ *-$//;s/  */ /g' "${localZshHostnameFile}"
fi
