#!/usr/bin/env bash
# vim: ft=bash ts=2 sw=2 sts=2 noexpandtab

# WARNING: hash git >/dev/null 2>&1
# Este comando (built-in), ha dado problemas bajo ciertos usuarios porque la tabla estaba vacía.
# Una forma de reconstruirla es con el comando «hash -f».
# Con esto el problema puede que quedase solucionado, pero como este script puede ejecutarse en todos los fsservers,
# se ha decidido optar por el comando «which».

enableColors() {
  # Use colors, but only if connected to a terminal, and that terminal
  # supports them.
  if command -v tput >/dev/null 2>&1; then
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
}

oh_my_zsh_install() {
  CHECK_ZSH_INSTALLED=$(/bin/grep /zsh$ /etc/shells | wc -l)
  if [[ ! ${CHECK_ZSH_INSTALLED} -ge 1 ]]; then
    echo -e "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit 1
  fi
  unset CHECK_ZSH_INSTALLED

  if [[ -z "${ZSH}" ]]; then
    ZSH=~/.oh-my-zsh
  fi

  if [[ -d "${ZSH}" ]]; then
    upgradeScript="${ZSH}/tools/upgrade.sh"
    echo -e "\n\n\n================================================================\n"
    echo -e "${YELLOW}You already have Oh My Zsh installed.${NORMAL}\n"
    echo -e "You'll need to remove ${ZSH} if you want to re-install.\n"
    echo -e "================================================================\n\n"
    echo -e "[RUN] ${upgradeScript} \n\n"

    env ZSH=${ZSH} sh "${upgradeScript}"

    return 0
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo -e "${BLUE}Cloning Oh My Zsh…${NORMAL}\n"
  # WARNING: hash git >/dev/null 2>&1 || {
  command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [[ "$OSTYPE" == cygwin ]]; then
    if git --version | /bin/grep -i msysgit >/dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  # env git clone --depth=1 https://github.com/robbyrussell/oh-my-zsh.git ${ZSH} || {
  env git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ${ZSH} || {
    echo -e "Error: git clone of oh-my-zsh repo failed\n"
    exit 1
  }

  echo -e "${BLUE}Looking for an existing zsh config…${NORMAL}\n"
  if [[ -f ~/.zshrc ]] || [[ -L ~/.zshrc ]]; then
    echo -e "${YELLOW}Found ~/.zshrc.${NORMAL} ${GREEN}Backing up to ~/.zshrc.pre-oh-my-zsh${NORMAL}\n"
    mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh
  fi

  echo -e "${BLUE}Using the Oh My Zsh template file and adding it to ~/.zshrc${NORMAL}\n"
  cp ${ZSH}/templates/zshrc.zsh-template ~/.zshrc
  sed "/^export ZSH=/ c\\
    export ZSH=$ZSH
    " ~/.zshrc >~/.zshrc-omztemp
  mv -f ~/.zshrc-omztemp ~/.zshrc

  # If this user's login shell is not already "zsh", attempt to switch.
  TEST_CURRENT_SHELL=$(expr "$SHELL" : '.*/\(.*\)')
  if [[ "$TEST_CURRENT_SHELL" != "zsh" ]]; then
    # If this platform provides a "chsh" command (not Cygwin), do it, man!
    # WARNING: if hash chsh >/dev/null 2>&1; then
    if command -v chsh >/dev/null 2>&1; then
      echo -e "${BLUE}Time to change your default shell to zsh, if you want!${NORMAL}\n"
      if whoami | grep -q '^root'; then
        echo -e "${RED}Execute: "
        echo -e 'chsh -s $(grep /zsh$ /etc/shells | tail -1)'"${NORMAL}\n"
      else
        chsh -s "$(grep /zsh$ /etc/shells | tail -1)"
      fi
    # Else, suggest the user do so manually.
    else
      echo -e "I can't change your shell automatically because this system does not have chsh.\n"
      echo -e "${BLUE}Please manually change your default shell to zsh!${NORMAL}\n"
    fi
  fi

  echo -e "${GREEN}"
  echo '         __                                     __   '
  echo '  ____  / /_     ____ ___  __  __   ____  _____/ /_  '
  echo ' / __ \/ __ \   / __ `__ \/ / / /  /_  / / ___/ __ \ '
  echo '/ /_/ / / / /  / / / / / / /_/ /    / /_(__  ) / / / '
  echo '\____/_/ /_/  /_/ /_/ /_/\__, /    /___/____/_/ /_/  '
  echo '                        /____/                       ....is now installed!'
  echo ''
  echo ''
  echo 'Please look over the ~/.zshrc file to select plugins, themes, and options.'
  echo ''
  echo 'p.s. Follow us at https://twitter.com/ohmyzsh.'
  echo ''
  echo 'p.p.s. Get stickers and t-shirts at http://shop.planetargon.com.'
  echo ''
  echo -e "${NORMAL}"
}

mfontc_home_install() {
  CHECK_ZSH_INSTALLED="$(grep /zsh$ /etc/shells | wc -l)"
  if [[ ! ${CHECK_ZSH_INSTALLED} -ge 1 ]]; then
    echo -e "${YELLOW}Zsh is not installed!${NORMAL} Please install zsh first!\n"
    exit 1
  fi
  unset CHECK_ZSH_INSTALLED

  MFONTC_HOME=~/.mfontc_home
  MFONTC_ZSH="${MFONTC_HOME}/oh-my-zsh"

  if [[ -d "${MFONTC_HOME}" ]]; then
    echo -e "\n\n\n================================================================\n"
    echo -e "${YELLOW}You already have mfontc_home installed.${NORMAL}\n"
    echo -e "You'll need to remove ${MFONTC_HOME} if you want to re-install.\n"
    echo -e "================================================================\n\n"
    upgradeScript="${MFONTC_ZSH}/tools/upgrade_oh_my_zsh_mfontc.sh"
    if [[ ! -f "${upgradeScript}" ]]; then
      upgradeScript="${MFONTC_HOME}/bin/upgrade_oh_my_zsh_mfontc"
    fi
    if [[ ! -f "${upgradeScript}" ]]; then
      echo -e "\n\n\n================================================================\n"
      echo -e "${RED}No se ha podido encontrar ningún script para actualizar el ~/.mfontc_home.${NORMAL}\n"
      echo -e "${RED}Debes eliminar el directorio ~/.mfontc_home y volver a lanzar este script.${NORMAL}\n"
      echo -e "================================================================\n\n"
      return 1
    fi
    echo -e "[RUN] ${upgradeScript} \n\n"

    zsh "${upgradeScript}"

    return 0
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  echo -e "${BLUE}Cloning mfontc_home…${NORMAL}\n"
  # WARNING: hash git >/dev/null 2>&1 || {
  command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [[ "$OSTYPE" == cygwin ]]; then
    if git --version | grep msysgit >/dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --depth=1 https://6f2f86862affbc7a6596f4a8c39b79d72c3adc5f@github.com/DFLabsTechSolutions/mfontc_home.git ${MFONTC_HOME} || {
    echo -e "Error: git clone of mfontc_home repo failed\n"
    exit 1
  }

  # Actualizamos los enlaces necesarios.
  env "${MFONTC_ZSH}/tools/upgrade_oh_my_zsh_mfontc.sh"
  cd
}

modify_bash_aliases_if_exists() {
  bashAliases=~/.bash_aliases
  if [[ -f "${bashAliases}" ]]; then
    cat <<'EOF' >"${bashAliases}"
if [ -d ~/.mfontc_home ]; then
    function _() {
        env zsh
    }
elif [ -f ~/.bash_aliases_myown ]; then
    function _() {
        source ~/.bash_aliases_myown
    }
    if [ -f ~/.bash_aliases_myown -a -f ~/.bash_myown ]; then
        source ~/.bash_aliases_myown
    fi
fi
EOF
  fi
}

enableColors
oh_my_zsh_install
mfontc_home_install
modify_bash_aliases_if_exists

# Si no estamos todavía en un zsh, entramos en uno.
echo -e "${RED}Si todavía no estás en un zsh, ejecuta el comando 'env zsh'.${NORMAL}\n"
