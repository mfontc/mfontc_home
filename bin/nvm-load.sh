#!/usr/bin/env zsh
# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

# ------------------------------------------------------------------------------
if [[ $_ != "$0" ]] ; then
  if [[ -d "${HOME}/.nvm" ]] ; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && source "${NVM_DIR}/nvm.sh"  # This loads nvm
    [ -s "${NVM_DIR}/bash_completion" ] && source "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion
  fi
else
  echo "Can't load nvm in the shell. The script must be sourced!"
  echo
  echo "source $0"
  echo
fi

