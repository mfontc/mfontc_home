# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab

# ------------------------------------------------------------------------------
# Hostname Titles
local  ZSH_PROMPT_TITLE_FILE="${ZSH_MFONTC}/.zsh_hostname"
local BASH_PROMPT_TITLE_FILE="${HOME}/.bash_hostname"

[[ ! -f "$ZSH_PROMPT_TITLE_FILE" && -f "$BASH_PROMPT_TITLE_FILE" ]] && cp "$BASH_PROMPT_TITLE_FILE" "$ZSH_PROMPT_TITLE_FILE"
export ZSH_PROMPT_TITLE="$( [ -f "$ZSH_PROMPT_TITLE_FILE" ] && cat "$ZSH_PROMPT_TITLE_FILE" )"

# ------------------------------------------------------------------------------
# Default prompt colors
local ZSH_PROMPT_DEFAULT_COLORS="${ZSH_MFONTC}/.zsh_default_colors"

export ZSH_PROMPT_BG="$(  [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f1 -d';' )"
export ZSH_PROMPT_FG="$(  [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f2 -d';' )"
export ZSH_PROMPT_FG0="$( [ -f "$ZSH_PROMPT_DEFAULT_COLORS" ] && cat "$ZSH_PROMPT_DEFAULT_COLORS" | cut -f3 -d';' )"

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# MySQL prompt
export MYSQL_PS1="\p (\u@\h) [\d]>\_"

# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
alias    vim="vim -u $HOME_MFONTC/config/vimrc -p"
alias    screen="screen -c $HOME_MFONTC/config/screenrc -U -D -RR"
function pbcopy()   { xclip -selection clipboard; }
function pbpaste()  { xclip -selection clipboard -o; }
function copydir()  { pwd | tr -d "\r\n" | pbcopy; }
function copyfile() { [[ "$#" != 1 ]] && return 1; local file_to_copy=$1; cat $file_to_copy | pbcopy; }
function search-into-files() { find . -type f -print0 | xargs -0 -n 100 grep --color --ignore-case -n "$*"; }
function _mfontc-git-prompt() { if [[ "$ZSH_PROMPT_GIT" == "yes" ]]; then export ZSH_PROMPT_GIT="no"; else export ZSH_PROMPT_GIT="yes"; fi; }
function _mfontc-show-paths() { echo -e ${PATH//:/\\n}; }
function _mfontc-du()         { du | grep ".*\./[^/]*$\|.*\.$" | sort -n; }
function _mfontc-df()         { df -Th; }
function _mfontc-tree()       { tree -a -N -A -C -h --noreport --dirsfirst; }
function _mfontc-ps()         { ps -U $USER -u $USER uf; }
function _mfontc-ps-all()     { ps auxfww; }
function _mfontc-ps-time()    { ps -eo "lstart,cmd"; }
function _mfontc-netstat()    { sudo netstat -patuW; }
function _mfontc-xurro()      { dd if=/dev/urandom bs=512 count=1 2> /dev/null | tr -dc '[:print:]'; echo; }
function _mfontc-calculator() { echo "$*" | bc -l; }
function _mfontc-benchmark()  { local t0=$(date +%s.%N); echo "2^2^20" | bc > /dev/null; local t1=$(date +%s.%N); local secs=$(echo "$t1 - $t0" | bc); echo "Calculate 2^2^20 in $secs secs"; }

