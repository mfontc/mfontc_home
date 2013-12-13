# -----------------------------------------------------------------------------
# Manuel Font Colonques - 2013-12-10
# -----------------------------------------------------------------------------



# -----------------------------------------------------------------------------
# Hostname Titles

local  ZSH_PROMPT_TITLE_FILE="${ZSH_MFONTC}/.zsh_hostname"
local BASH_PROMPT_TITLE_FILE="${HOME}/.bash_hostname"

[[ ! -f "$ZSH_PROMPT_TITLE_FILE" && -f "$BASH_PROMPT_TITLE_FILE" ]] && cp "$BASH_PROMPT_TITLE_FILE" "$ZSH_PROMPT_TITLE_FILE"
export ZSH_PROMPT_TITLE="$( [ -f "$ZSH_PROMPT_TITLE_FILE" ] && cat "$ZSH_PROMPT_TITLE_FILE" )"



# -----------------------------------------------------------------------------
# Default prompt colors
local ZSH_PROMPT_DEFAULT_COLORS="${ZSH_MFONTC}/.zsh_default_colors"

export ZSH_PROMPT_BG="$(  [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f1 -d';' )"
export ZSH_PROMPT_FG="$(  [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f2 -d';' )"
export ZSH_PROMPT_FG0="$( [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f3 -d';' )"



# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# MySQL prompt
export MYSQL_PS1="\p (\u@\h) [\d]>\_"



# -----------------------------------------------------------------------------
# Functions

function echo_()      { [ "$ZSH" ] && print -P    -- "%{$fg[green]%}$*%{$FX[reset]%}" || echo -e    "$*"; }
function echoInfo()   { [ "$ZSH" ] && print -P -n -- "%{$fg[blue]%}$*%{$FX[reset]%}"  || echo -e -n "$*"; }
function echoE()      { [ "$ZSH" ] && print -P    -- "%{$fg[red]%}$*%{$FX[reset]%}" &> /dev/stderr || echo -e "$*" &> /dev/stderr; }
function cont_()      { for i in `seq 1 3`; do echoInfo '.'; sleep 0.5; done; echo; }
function pause_()     { echoInfo "--- PAUSE [press 'q' to break the execution of the script] "; read -n 1 opt; case "$opt" in ; q|Q) echo; exit 1;; esac; }
function yes_or_no_() { echoInfo "$* [Y/n] "; read -n 1 opt; case "$opt" in; n|N) echo; return 1;; esac; }
function got_root()   { [[ $USER == "root" ]] || { echoE "### You must be root to run this!"; return 1; } ; }
function got_utf8()   { case none"$LANG$LC_ALL$LC_CTYPE" in ; *utf8*|*UTF-8*) return 0;; *) echoE "### This script must be run in a UTF-8 locale"; return 1;; esac; }
function my_hex_cat() { objdump -d $1 | less; }
function my_calc()    { echo "$*" | bc -l; }

_now="$( date +%Y-%m-%d_%H-%M-%S )" || exit 1
_day="$( date +%Y-%m-%d          )" || exit 1



# -----------------------------------------------------------------------------
# Aliases

# ls, the common ones I use a lot shortened for rapid fire usage
alias    ls='ls --color --time-style=long-iso'
alias     l='ls -lAF'
alias    ll='ls -lF'
alias    lh='ls -lAFh'
alias   llh='ls -lFh'
alias  ldot='ls -ld .*'
alias     q='exit'
alias    ..='cd ../'
alias   ...='cd ../../'
alias  ....='cd ../../../'
alias .....='cd ../../../../'

alias hgrep="fc -El 0 | grep"

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
#alias rm_tmp='rm -rfv *~ .*~'

alias zshrc='vim ~/.zshrc' # Quick access to the ~/.zshrc file

alias  grep='grep --color'
alias sgrep='grep -R -n -H -C 5 --exclude-dir={.git,.svn,CVS} '

# Command line head / tail shortcuts
alias -g H='| head'
alias -g T='| tail'
alias -g G='| grep'
alias -g L="| less"
alias -g M="| most"
alias -g LL="2>&1 | less"
alias -g CA="2>&1 | cat -A"
alias -g NE="2> /dev/null"
alias -g NUL="> /dev/null 2>&1"
alias -g P="2>&1| pygmentize -l pytb"

alias unexport='unset'

# More aliases...
alias  my_screen='screen -T xterm -U -D -RR'
alias my_netstat='sudo netstat -patuW'
alias      my_ps='ps -U $USER -u $USER uf'
alias  my_ps_all='ps auxfww'
alias my_ps_time='ps -eo "lstart,cmd"'
alias    my_tree='tree -a -N -A -C -h --noreport --dirsfirst'
alias      my_du='du | grep ".*\./[^/]*$\|.*\.$" | sort -n'
alias      my_df='df -Th'

alias    search_into_files="find . -type f -print0 | xargs -0 -n 100 grep --color --ignore-case -n "
alias        my_show_paths='echo -e ${PATH//:/\\n}'
alias my_benchmark_in_bash='echo "2^2^20" | time -p bc > /dev/null'
alias                xurro="dd if=/dev/urandom bs=512 count=1 2> /dev/null | tr -dc '[:print:]'; echo"

which trickle &> /dev/null && {
    alias bandwith_100_KB_s='trickle -s -d 100 -u 10'
    alias bandwith_250_KB_s='trickle -s -d 250 -u 25'
    alias bandwith_500_KB_s='trickle -s -d 500 -u 50'
}

# -----------------------------------------------------------------------------
# Aliases 2

# zsh is able to auto-do some kungfoo
# depends on the SUFFIX :)
if [ ${ZSH_VERSION//\./} -ge 420 ]; then
  # open browser on urls
  _browser_fts=(htm html de org net com at cx nl se dk dk php)
  for ft in $_browser_fts ; do alias -s $ft=$BROWSER ; done

  _editor_fts=(cpp cxx cc c hh h inl asc txt TXT tex)
  for ft in $_editor_fts ; do alias -s $ft=$EDITOR ; done

  _image_fts=(jpg jpeg png gif mng tiff tif xpm)
  for ft in $_image_fts ; do alias -s $ft=$XIVIEWER; done

  _media_fts=(avi mpg mpeg ogm mp3 wav ogg ape rm mov mkv)
  for ft in $_media_fts ; do alias -s $ft=mplayer ; done

  #read documents
  alias -s pdf=acroread
  alias -s ps=gv
  alias -s dvi=xdvi
  alias -s chm=xchm
  alias -s djvu=djview

  #list whats inside packed file
  alias -s zip="unzip -l"
  alias -s rar="unrar l"
  alias -s tar="tar tf"
  alias -s tar.gz="echo "
  alias -s ace="unace l"
fi

# Make zsh know about hosts already accessed by SSH
zstyle -e ':completion:*:(ssh|scp|sshfssftp|rsh|rsync):hosts' hosts 'reply=(${=${${(f)"$(cat {/etc/ssh_,~/.ssh/known_}hosts(|2)(N) /dev/null)"}%%[# ]*}//,/ })'



# -----------------------------------------------------------------------------
# FUNCTIONS: Package Management

function PKG_upgrade() {
    which aptitude &> /dev/null && {
        echo_ "#\n# Updating packets list...\n#"; sudo aptitude update       || return 1
        echo_ "#\n# Upgrading system...\n#";      sudo aptitude dist-upgrade || return 1
        echo_ "#\n# Cleaning cache data...\n#";   sudo aptitude clean        || return 1
    } || {
        sudo apt-get install aptitude && PKG_upgrade || return 1
    }
}

function PKG_upgrade_safe() {
    which aptitude &> /dev/null && {
        echo_ "#\n# Updating packets list...\n#"; sudo aptitude update       || return 1
        echo_ "#\n# SAFE upgrading system...\n#"; sudo aptitude safe-upgrade || return 1
        echo_ "#\n# Cleaning cache data...\n#";   sudo aptitude clean        || return 1
    } || {
        sudo apt-get install aptitude && PKG_upgrade_safe || return 1
    }
}

function PKG_upgrade_FORCE_YES() {
    echo_ "#\n# Updating packets list...\n#"; sudo apt-get update           || return 1
    echo_ "#\n# Upgrading system...\n#";      sudo apt-get dist-upgrade -yf || return 1
    echo_ "#\n# Checking system...\n#";       sudo apt-get check            || return 1
    echo_ "#\n# Cleaning cache...\n#";        sudo apt-get clean            || return 1
}

function PKG_clear_old_config_files() {
    echo_ "#\n# Cleaning configuration files of deleted packages...\n#"
    dpkg -l | grep ^rc && sudo dpkg -P $( dpkg -l | grep ^rc | awk '{print $2}' ) || echo "Everything is clean..."
}

function PKG_show_downloadables() {
    apt-get -qq --print-uris dist-upgrade 2> /dev/null | awk '{ printf "%9.2f %s\n", $3/1024, $1 }' | sort -rn
}

function PKG_global_info() {
    which aptitude &> /dev/null && {
        echo_ "#\n# System package information...\n#"
        echo -n "dpkg-selections:      "; dpkg --get-selections   | wc -l
        echo -n "apt-installed:        "; aptitude search '~i'    | wc -l
        echo -n "apt-installed-manual: "; aptitude search '~i!~M' | wc -l
        echo -n "apt-installed-auto:   "; aptitude search '~i ~M' | wc -l
    } || {
        sudo apt-get install aptitude && PKG_global_info || return 1
    }
}

function PKG_search_for_file() {
    which apt-file &> /dev/null && {
        file="$*"
        echo_ "\n>>> Searching for file «${file}»"
        sudo apt-file search ${file}
    } || {
        echo -n -e "\n >>> The programm 'apt-file' is not installed. Do you want to install it? "
        yes_or_no_ && \
            sudo apt-get install apt-file && \
            sudo apt-file update && \
            PKG_search_for_file ${file}
    }
}

function my_deborphan-recursive() {
    which deborphan &> /dev/null || {
        sudo apt-get install deborphan || return 1
    }

    while [ -n "`deborphan`" ]; do
        deborphan; echo
        sudo aptitude purge `deborphan` || exit 1
    done
}

function my_deborphan-show-all-by-size() {
    which deborphan &> /dev/null || {
        sudo apt-get install deborphan || return 1
    }

    deborphan --all-packages --no-show-section --show-priority --show-size | sort -n
}



# -----------------------------------------------------------------------------
# FUNCTIONS: 

function my_hardware_list() {
    for dmitype in bios system baseboard chassis processor memory cache connector slot; do
        echo_ "#\n# dmidecode --type $dmitype\n#"
        sudo dmidecode --type $dmitype
    done
}

# -----------------------------------------------------------------------------
# nmap

function my_nmap_local_IP_discover() {
    which nmap &> /dev/null || {
        sudo apt-get install nmap || return 1
    }

    ip_and_netmask="$1"
    if [[ -z "${ip_and_netmask}" ]]; then
        ip_and_netmask=$( ifconfig  | grep 'inet addr:'| grep -v '127.0.0.1' | cut -d: -f2 | awk '{ print $1}' | grep -v '^25' | head -n 1 )
        ip_and_netmask="${ip_and_netmask}/24"
    fi

    echo_ "#\n# Local IP discover\n# Using this IP/NetMask: ${ip_and_netmask}\n#"
    sudo nmap -sn $ip_and_netmask | grep -v "^Host is up" | grep "^Nmap scan report for" | sed "s/^Nmap scan report for *//;s/\(.*\)  *(\(.*\))/\2\t\1/"
}

function my_nmap() {
    which nmap &> /dev/null || {
        sudo apt-get install nmap || return 1
    }

    dst="$1"
    if [[ -z "${dst}" ]]; then
        echoE "### ERROR: Unknown destination"
        exit 1
    fi

    echo_ "#\n# Scanning $dst\n#"
    opt="$2"
    case $opt in
        1)
            echo_ "    Quick and detectable scan"
            sudo nmap -v -T5 -O -sS     -sV -p- $dst
            ;;
        2)
            echo_ "    Aggressive scan"
            sudo nmap -v -T2 -O -sS -sU -sV -P0 $dst
            ;;
        *)
            echo_ "    Default scan"
            sudo nmap -v     -O -sS -sU -sV -P0 $dst
            ;;
    esac
}

