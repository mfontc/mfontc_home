#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

# -----------------------------------------------------------------------------
# Use colors, but only if connected to a terminal, and that terminal
# supports them.
if which tput >/dev/null 2>&1; then
  ncolors=$(tput colors)
fi
if [[ -t 1 ]] && [[ -n "$ncolors" ]] && [[ "$ncolors" -ge 8 ]]; then
  RED="$(tput setaf 1)"
  GREEN="$(tput setaf 2)"
  YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"
  BOLD="$(tput bold)"
  NORMAL="$(tput sgr0)"
else
  RED=""
  GREEN=""
  YELLOW=""
  BLUE=""
  BOLD=""
  NORMAL=""
fi

# Only enable exit-on-error after the non-critical colorization stuff,
# which may fail on systems lacking tput or terminfo
set -e

# -----------------------------------------------------------------------------
MFONTC_HOME=~/.mfontc_home
MFONTC_ZSH="${MFONTC_HOME}/oh-my-zsh"

# -----------------------------------------------------------------------------
# El directorio debe existir.
cd "${MFONTC_HOME}" || exit 1

# -----------------------------------------------------------------------------
printf "\n${BLUE}Updating Oh My Zsh mfontc${NORMAL}\n"

# -----------------------------------------------------------------------------
# GIT PULL!!!
if [[ -f "${MFONTC_HOME}/.devel" ]] ; then
  # WARNING: Precaución por si se va a ejecutar en desarrollo.
  printf "\n${YELLOW}[ WARNING ] Cannot run the «git» commands because you are in the development project${NORMAL}\n\n\n"
else
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  which git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }

  # Elimina toda modificación hecha sobre la rama que difiera sobre origin/master.
  git fetch --all || exit 1
  git reset --hard origin/master || exit 1

  # Sólo se actualizará si se puede realizar un fast-forward.
  git pull origin master --ff-only || exit 1

  # Por último, limpiamos la cache.
  git gc --aggressive --quiet || exit 1
fi

# -----------------------------------------------------------------------------
# ~/.zshrc & ~/.zshenv
_zshrcWanted=${HOME}/.zshrc
_zshrcTarget=$(readlink -f "${_zshrcWanted}")
_zshrcReal="${MFONTC_ZSH}/zshrc"
if [[ "${_zshrcTarget}" != "${_zshrcReal}" ]]; then
  rm -f "${_zshrcWanted}"
  ln -s "${_zshrcReal}" "${_zshrcWanted}"
  printf "\n${BLUE}Created the ZSH link ${_zshrcWanted}${NORMAL}\n"
fi

_zshenvWanted=${HOME}/.zshenv
_zshenvTarget=$(readlink -f "${_zshenvWanted}")
_zshenvReal="${MFONTC_ZSH}/zshenv"
if [[ "${_zshenvTarget}" != "${_zshenvReal}" ]]; then
  rm -f "${_zshenvWanted}"
  ln -s "${_zshenvReal}" "${_zshenvWanted}"
  printf "\n${BLUE}Created the ZSH link: ${_zshenvWanted}${NORMAL}\n"
fi

# -----------------------------------------------------------------------------
# ZSH CUSTOM BASE THEMES
_omzCustomThemesPath="${HOME}/.oh-my-zsh/custom/themes"
if [[ ! -d "${_omzCustomThemesPath}" ]]; then
  mkdir -p "${_omzCustomThemesPath}"
  printf "${BLUE}Created the ZSH custom themes: ${_omzCustomThemesPath}${NORMAL}\n"
fi

# ZSH CUSTOM THEMES «mfontc»
_mfontcThemeWanted="${_omzCustomThemesPath}/mfontc.zsh-theme"
_mfontcThemeTarget=$(readlink -f "${_mfontcThemeWanted}")
_mfontcThemeReal="${MFONTC_ZSH}/custom/themes/mfontc.zsh-theme"
if [[ "${_mfontcThemeTarget}" != "${_mfontcThemeReal}" ]]; then
  rm -f "${_mfontcThemeWanted}"
  ln -s "${_mfontcThemeReal}" "${_mfontcThemeWanted}"
  printf "${BLUE}Created the link to the ZSH custom mfontc theme: ${_mfontcThemeWanted}${NORMAL}\n"
fi

# BUG: Es posible que se haya creado un enlace directo que debe eliminarse.
_wrongThemeLinkToDelete="${_omzCustomThemesPath}/themes"
if [[ -L "${_wrongThemeLinkToDelete}" ]]; then
  rm -f "${_wrongThemeLinkToDelete}"
fi

# -----------------------------------------------------------------------------
# ZSH CUSTOM PLUGINS «mfontc»
_mfontcPluginWanted="${HOME}/.oh-my-zsh/custom/plugins/mfontc"
_mfontcPluginTarget=$(readlink -f "${_mfontcPluginWanted}")
_mfontcPluginReal="${MFONTC_ZSH}/custom/plugins/mfontc"
if [[ "${_mfontcPluginTarget}" != "${_mfontcPluginReal}" ]]; then
  rm -f "${_mfontcPluginWanted}"
  ln -s "${_mfontcPluginReal}" "${_mfontcPluginWanted}"
  printf "${BLUE}Created the link to the ZSH custom mfontc plugin: ${_mfontcPluginWanted}${NORMAL}\n"
fi

# -----------------------------------------------------------------------------
# Inicializamos el fichero de colores, si fuese necesario.
_zshPromptColorsFile="${MFONTC_ZSH}/.zsh_default_colors"
if [[ ! -f "${_zshPromptColorsFile}" ]] ; then
  if whoami | grep -q '^root' ; then
    echo "black;red;red" > "${_zshPromptColorsFile}"
  else
    echo "black;white;red" > "${_zshPromptColorsFile}"
  fi
  printf "\n${BLUE}Created the ZSH prompt colors file: ${_zshPromptColorsFile}${NORMAL}\n"
fi

# -----------------------------------------------------------------------------
# Inicializamos el fichero de nombre del servidor, si fuese necesario.
_zshPromptHostnameFile="${MFONTC_ZSH}/.zsh_hostname"
if [[ ! -f "${_zshPromptHostnameFile}" ]] ; then
  source "${MFONTC_HOME}/bin/editZshHostname.sh"
fi
if [[ -f "${_zshPromptHostnameFile}" ]]; then
  if [[ "$(whoami)" != "root" ]]; then
    source "${MFONTC_HOME}/bin/editZshHostname.sh"
  fi
fi

# -----------------------------------------------------------------------------
printf "\n${BLUE}\n\n\n--------------------------------${NORMAL}\n"
