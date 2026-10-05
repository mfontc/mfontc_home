# vim: ft=zsh ts=2 sw=2 sts=2 noexpandtab

# ------------------------------------------------------------------------------
# Hostname Titles
local  ZSH_PROMPT_TITLE_FILE="${MFONTC_ZSH}/.zsh_hostname"
export ZSH_PROMPT_TITLE="$( [ -f "$ZSH_PROMPT_TITLE_FILE" ] && cat "$ZSH_PROMPT_TITLE_FILE" )"

# ------------------------------------------------------------------------------
# Default prompt colors
local ZSH_PROMPT_DEFAULT_COLORS="${MFONTC_ZSH}/.zsh_default_colors"

export ZSH_PROMPT_BG="$(  [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f1 -d';' )"
export ZSH_PROMPT_FG="$(  [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f2 -d';' )"
export ZSH_PROMPT_FG0="$( [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f3 -d';' )"

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# MySQL prompt
export MYSQL_PS1="\p (\u@\h) [\d]>\_"

# ------------------------------------------------------------------------------
# Aliases
alias     l='ls --color --time-style=long-iso -lAF'
alias    ll='ls --color --time-style=long-iso -lF'
alias    lh='ls --color --time-style=long-iso -lAFh'
alias   llh='ls --color --time-style=long-iso -lFh'
alias  ldot='ls --color --time-style=long-iso -ld .*'
alias     q='exit'
alias    ..='cd ../'
alias   ...='cd ../../'
alias  ....='cd ../../../'
alias .....='cd ../../../../'

alias hgrep="fc -El 0 | grep" # Busca en el history aplicando un grep. Ej: hgrep apache2

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

alias unexport='unset'

# ------------------------------------------------------------------------------
# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sshfssftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'

# ------------------------------------------------------------------------------
alias    vimm="vim -u ${MFONTC_HOME}/config/vimrc -p"
alias    screen="screen -c ${MFONTC_HOME}/config/screenrc -U -D -RR"
function pbcopy()   { xclip -selection clipboard; }
function pbpaste()  { xclip -selection clipboard -o; }
function copydir()  { pwd | tr -d "\r\n" | pbcopy; }
function copyfile() { [[ "$#" != 1 ]] && return 1; local file_to_copy=$1; cat $file_to_copy | pbcopy; }
function search-into-files() { find . -type f -print0 | xargs -0 -n 100 grep --color=always --ignore-case -n "$*"; }
function _mfontc-git-prompt() { if [[ "$ZSH_PROMPT_GIT" == "yes" ]]; then export ZSH_PROMPT_GIT="no"; else export ZSH_PROMPT_GIT="yes"; fi; }
function _mfontc-show-paths() { echo -e ${PATH//:/\\n}; }
function _mfontc-du()         { du -h | grep ".*\./[^/]*$\|.*\.$" | sort -h; }
function _mfontc-df()         { df -Th; }
function _mfontc-tree()       { tree -a -N -A -C -h --noreport --dirsfirst; }
function _mfontc-ps()         { ps -U $USER -u $USER uf; }
function _mfontc-ps-all()     { ps auxfww; }
function _mfontc-ps-time()    { ps -eo "lstart,cmd"; }
function _mfontc-netstat()    { sudo netstat -patuW; }
function _mfontc-xurro()      { dd if=/dev/urandom bs=512 count=1 2> /dev/null | tr -dc '[:print:]'; echo; }
function _mfontc-calculator() { echo "$*" | bc -l; }
function _mfontc-benchmark()  { local t0=$(date +%s.%N); echo "2^2^20" | bc > /dev/null; local t1=$(date +%s.%N); local secs=$(echo "$t1 - $t0" | bc); echo "Calculate 2^2^20 in $secs secs"; }

# ------------------------------------------------------------------------------
# LESS options
export LESS='--quit-if-one-screen --ignore-case --status-column --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'
export LESS_TERMCAP_mb=$'\E[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\E[1;36m'     # begin blink
export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
export LESS_TERMCAP_so=$'\E[01;44;33m' # begin reverse video
export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

# ------------------------------------------------------------------------------
function upgrade_oh_my_zsh_mfontc() {
  env MFONTC_ZSH=${MFONTC_ZSH} zsh -f "${MFONTC_ZSH}/tools/upgrade_oh_my_zsh_mfontc.sh"

  omz update
}

# ------------------------------------------------------------------------------
# Unaliases
unalias grep
unalias ls
