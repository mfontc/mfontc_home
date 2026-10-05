#!/usr/bin/env zsh

if [[ -z "${DISABLE_UPDATE_PROMPT}" ]] ; then
  DISABLE_UPDATE_PROMPT="false"
fi
if [[ -z "${MFONTC_HOME}" ]] ; then
  MFONTC_HOME="${HOME}/.mfontc_home"
fi
if [[ -z "${MFONTC_ZSH}" ]] ; then
  MFONTC_ZSH="${MFONTC_HOME}/oh-my-zsh"
fi
if [[ -z "${MFONTC_ZSH_CACHE_DIR}" ]] ; then
  MFONTC_ZSH_CACHE_DIR="${MFONTC_ZSH}/cache"
fi
if [[ -z "${MFONTC_ZSH_LOG_DIR}" ]] ; then
  MFONTC_ZSH_LOG_DIR="${MFONTC_ZSH}/log"
fi

zmodload zsh/datetime

function _mfontc_current_epoch() {
  echo $(( $EPOCHSECONDS / 60 / 60 / 24 ))
}

function _mfontc_update_zsh_update() {
  echo "MFONTC_LAST_EPOCH=$(_mfontc_current_epoch)" >! "${MFONTC_ZSH_CACHE_DIR}/.mfontc-zsh-update"
}

function _mfontc_upgrade_zsh() {
  # WARNING: Precaución por si se va a ejecutar en desarrollo.
  if [[ -f "${MFONTC_HOME}/.devel" ]] ; then
    echo "No se puede ejecutar el comando «$0» porque estás en el directorio de desarrollo."
  else
    env MFONTC_ZSH=${MFONTC_ZSH} zsh -f "${MFONTC_ZSH}/tools/upgrade_oh_my_zsh_mfontc.sh"
  fi
  _mfontc_update_zsh_update
}

# Default to old behavior
mfontc_epoch_target=8

# Cancel upgrade if the current user doesn't have write permissions for the oh-my-zsh directory.
[[ -w "${MFONTC_ZSH}" ]] || return 0

# Cancel upgrade if git is unavailable on the system.
whence git >/dev/null || return 0

if mkdir "${MFONTC_ZSH_LOG_DIR}/update.lock" 2>/dev/null; then
  MFONTC_LAST_EPOCH=
  if [[ -f "${MFONTC_ZSH_CACHE_DIR}/.mfontc-zsh-update" ]]; then
    . "${MFONTC_ZSH_CACHE_DIR}/.mfontc-zsh-update"

    if [[ -z "${MFONTC_LAST_EPOCH}" ]]; then
      _mfontc_update_zsh_update && return 0
    fi

    epoch_diff=$(($(_mfontc_current_epoch) - ${MFONTC_LAST_EPOCH}))
    if [[ ${epoch_diff} -gt ${mfontc_epoch_target} ]]; then
      if [[ "${DISABLE_UPDATE_PROMPT}" = "true" ]]; then
        _mfontc_upgrade_zsh
      else
        echo "[Oh My Zsh] Deberías ejecutar el comando «upgrade_oh_my_zsh_mfontc»."
        # echo "[Oh My Zsh] Would you like to update? [Y/n]: \c"
        # read line
        # if [[ "$line" == Y* ]] || [[ "$line" == y* ]] || [[ -z "$line" ]]; then
        #   _mfontc_upgrade_zsh
        # else
        #   _mfontc_update_zsh_update
        # fi
      fi
    fi
  else
    _mfontc_update_zsh_update
  fi

  rmdir "${MFONTC_ZSH_LOG_DIR}/update.lock"
fi
