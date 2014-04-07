# vim:ft=zsh ts=4 sw=4 sts=4 noexpandtab
#
# Based on agnoster's Theme - https://gist.github.com/3712874
# In order for this theme to render correctly, you will need a [Powerline-patched font](https://gist.github.com/1595572).
#

### Default colors by hostname
[ "$ZSH_PROMPT_BG" ]  || ZSH_PROMPT_BG='black'
[ "$ZSH_PROMPT_FG" ]  || ZSH_PROMPT_FG='blue'
[ "$ZSH_PROMPT_FG0" ] || ZSH_PROMPT_FG0='yellow'

ZSH_PROMPT_FG_USER_AND_HOST=$( [[ $UID -eq 0 ]] && echo "$ZSH_PROMPT_FG0" || echo "$ZSH_PROMPT_FG" )
ZSH_PROMPT_BG_GIT_CLEAN="$ZSH_PROMPT_BG"
ZSH_PROMPT_BG_GIT_DIRTY="$ZSH_PROMPT_FG0"

CURRENT_BG='NONE'

# Beautify prompt :-)
SEGMENT_SEPARATOR='\ue0b0'	# '\ue0b0'='▶'
GIT_BRANCH=''				# '\ue0a0'=''
#GIT_STAGED='\u220b'		# '\u220b'='∋'
#GIT_UNSTAGED='\u220c'		# '\u220c'='∌'
PROMPT_ERROR='\u2717'		# '\u2717'='✗'	'\u274c'='❌'
PROMPT_ROOT='\u26a1'		# '\u26a1'='⚡'
PROMPT_BG_JOBS='\u231a'		# '\u231a'='⌚'	'\u231b'='⌛'

# Unbeautify prompt on tty
tty | grep -q '^/dev/tty' && {
	SEGMENT_SEPARATOR=''
	GIT_BRANCH=''
	PROMPT_ERROR='! '
	PROMPT_ROOT='# '
	PROMPT_BG_JOBS='(bg) '
}

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts

# Begin a segment: Takes two arguments, background and foreground. Both can be omitted, rendering default background/foreground.
prompt_segment() {
	local bg fg
	[[ -n $1 ]] && bg="%K{$1}" || bg="%k"
	[[ -n $2 ]] && fg="%F{$2}" || fg="%f"
	if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
		echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
	else
		echo -n "%{$bg%}%{$fg%} "
	fi
	CURRENT_BG=$1
	[[ -n $3 ]] && echo -n $3
}

# End the prompt, closing any open segments
prompt_end() {
	if [[ -n $CURRENT_BG ]]; then
		echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
	else
		echo -n "%{%k%}"
	fi
	echo -n "%{%f%}"
	CURRENT_BG='NONE'
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Hostname
prompt_hostname() {
	if [[ -n "${ZSH_PROMPT_TITLE}" ]]; then
		prompt_segment $ZSH_PROMPT_BG $ZSH_PROMPT_FG "${ZSH_PROMPT_TITLE}"
	fi
}

# Time
prompt_time() {
	prompt_segment $ZSH_PROMPT_BG $ZSH_PROMPT_FG "─ %T"
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
	local user=`whoami`

	if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
		prompt_segment $ZSH_PROMPT_BG $ZSH_PROMPT_FG_USER_AND_HOST "${user}@%m"
	fi
}

# Git: branch/detached head, dirty status
prompt_git() {
	if [[ "$ZSH_PROMPT_GIT" == "yes" ]]; then
		local ref dirty
		if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
			dirty=$(parse_git_dirty)
			ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
			if [[ -n $dirty ]]; then
				prompt_segment $ZSH_PROMPT_BG_GIT_DIRTY $ZSH_PROMPT_BG
			else
				prompt_segment $ZSH_PROMPT_BG_GIT_CLEAN $ZSH_PROMPT_FG
			fi

			setopt promptsubst
			autoload -Uz vcs_info

			zstyle ':vcs_info:*' enable git
			zstyle ':vcs_info:*' get-revision true
			zstyle ':vcs_info:*' check-for-changes true
			#zstyle ':vcs_info:*' stagedstr "$GIT_STAGED"
			#zstyle ':vcs_info:git:*' unstagedstr "$GIT_UNSTAGED"
			zstyle ':vcs_info:*' formats ' %u%c'
			zstyle ':vcs_info:*' actionformats '%u%c'
			vcs_info
			echo -n "${ref/refs\/heads\//$GIT_BRANCH}${vcs_info_msg_0_}"
		fi
	fi
}

# Dir: current working directory
prompt_dir() {
	prompt_segment $ZSH_PROMPT_FG $ZSH_PROMPT_BG '%~'
}

# Status:
# - was there an error?
# - am I root?
# - are there background jobs?
prompt_status() {
	local symbols
	symbols=()
	[[ $RETVAL -ne 0 ]] && symbols+="%{%F{$ZSH_PROMPT_FG0}%}$PROMPT_ERROR"
	[[ $UID -eq 0 ]] && symbols+="%{%F{$ZSH_PROMPT_FG0}%}$PROMPT_ROOT"
	[[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{$ZSH_PROMPT_FG0}%}$PROMPT_BG_JOBS"

	[[ -n "$symbols" ]] && prompt_segment $ZSH_PROMPT_BG $ZSH_PROMPT_FG "$symbols"
}

## Main prompts
build_prompt() {
	RETVAL=$?
	prompt_hostname
	prompt_time
	prompt_end
	echo
	prompt_context
	prompt_status
	prompt_dir
	prompt_git
	prompt_end
}

PROMPT='%{%f%b%k%}$(build_prompt) '
