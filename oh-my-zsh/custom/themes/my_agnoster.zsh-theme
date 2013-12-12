# vim:ft=zsh ts=2 sw=2 sts=2
#
# agnoster's Theme - https://gist.github.com/3712874
#
# In order for this theme to render correctly, you will need a [Powerline-patched font](https://gist.github.com/1595572).
# In addition, I recommend the [Solarized theme](https://github.com/altercation/solarized/).
#

CURRENT_BG='NONE'
R_CURRENT_BG='NONE'

# SEGMENT_SEPARATOR='▶' ; R_SEGMENT_SEPARATOR=''
SEGMENT_SEPARATOR='\ue0b0'
SEGMENT_SEPARATOR_2='\ue0b1'
R_SEGMENT_SEPARATOR='\ue0b2'
R_SEGMENT_SEPARATOR_2='\ue0b3'

# GIT_BRANCH='' ; GIT_STAGED='∋' ; GIT_UNSTAGED='∌ '
GIT_BRANCH='\ue0a0'
GIT_STAGED='\u220B'
GIT_UNSTAGED='\u220C'
GIT_DIRTY='±'

# PROMPT_ERROR='❌' ; PROMPT_ROOT='⚡' ; PROMPT_BG_JOBS='⌛'
PROMPT_ERROR='\u274C'
PROMPT_ROOT='\u26A1'
PROMPT_BG_JOBS='\u231B'

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

# Begin a right-segment
r_prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $1 != $R_CURRENT_BG ]]; then
    echo -n " %{%F{$1}%K{$R_CURRENT_BG}%}$R_SEGMENT_SEPARATOR%{$bg%}%{$fg%} "
  else
    echo -n " %{$bg%}%{$fg%}$R_SEGMENT_SEPARATOR_2 "
  fi
  R_CURRENT_BG=$1
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
  CURRENT_BG=''
}

# End the right-prompt
r_prompt_end() {
  echo -n " %{%k%f%}"
  R_CURRENT_BG='NONE'
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# RIGHT: Hostname
r_prompt_hostname() {
  if [[ -n "${ZSH_PROMPT_TITLE}" ]]; then
    r_prompt_segment black default "%(!.%{%F{yellow}%}.)${ZSH_PROMPT_TITLE}"
  fi
}

# RIGHT: Time
r_prompt_time() {
  r_prompt_segment black default "%(!.%{%F{yellow}%}.)%T"
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$user@%m"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY="$GIT_DIRTY"
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi

    setopt promptsubst
    autoload -Uz vcs_info

    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:*' get-revision true
    zstyle ':vcs_info:*' check-for-changes true
    zstyle ':vcs_info:*' stagedstr "$GIT_STAGED"
    zstyle ':vcs_info:git:*' unstagedstr "$GIT_UNSTAGED"
    zstyle ':vcs_info:*' formats ' %u%c'
    zstyle ':vcs_info:*' actionformats '%u%c'
    vcs_info
    echo -n "${ref/refs\/heads\//$GIT_BRANCH }${vcs_info_msg_0_}"
    #echo -n "${ref/refs\/heads\//$GIT_BRANCH }$dirty"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue black '%~'
  #prompt_segment blue black
  #echo -n "$PWD" | sed 's;/; \xEE\x82\xB1 ;g'
}

# Status:
# - was there an error?
# - am I root?
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}$PROMPT_ERROR"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$PROMPT_ROOT"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$PROMPT_BG_JOBS"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

## Main prompts
build_r_prompt() {
  r_prompt_hostname
  r_prompt_time
  r_prompt_end
}

build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

RPROMPT='$(build_r_prompt)'
PROMPT='%{%f%b%k%}$(build_prompt) '
