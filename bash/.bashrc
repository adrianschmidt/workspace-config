# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
# force_color_prompt=yes

# if [ -n "$force_color_prompt" ]; then
#     if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
# 	# We have color support; assume it's compliant with Ecma-48
# 	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
# 	# a case would tend to support setf rather than setaf.)
# 	color_prompt=yes
#     else
# 	color_prompt=
#     fi
# fi

# if [ "$color_prompt" = yes ]; then
#     PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# else
#     PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
# fi
# unset color_prompt force_color_prompt

# get current branch in git repo
function parse_git_branch() {
    BRANCH=`git branch 2> /dev/null --color=never | sed -e '/^[^*]/d' -e 's/* \(.*\)/\1/'`
    if [ ! "${BRANCH}" == "" ]
    then
        STAT=`parse_git_dirty`
        echo "[$(tput setaf 2)${BRANCH}$(tput sgr0)${STAT}]"
    else
        echo ""
    fi
}

# get current status of git repo
function parse_git_dirty {
    status=`git status 2>&1 | tee`
    stagedchanges=`echo -n "${status}" 2> /dev/null | grep "Changes to be committed:" &> /dev/null; echo "$?"`
    unstagedchanges=`echo -n "${status}" 2> /dev/null | grep "Changes not staged for commit:" &> /dev/null; echo "$?"`
    untracked=`echo -n "${status}" 2> /dev/null | grep "Untracked files" &> /dev/null; echo "$?"`
    ahead=`echo -n "${status}" 2> /dev/null | grep "Your branch is ahead of" &> /dev/null; echo "$?"`
    behind=`echo -n "${status}" 2> /dev/null | grep "Your branch is behind" &> /dev/null; echo "$?"`
    diverged=`echo -n "${status}" 2> /dev/null | grep "have diverged" &> /dev/null; echo "$?"`
    # dirty=`echo -n "${status}" 2> /dev/null | grep "modified:" &> /dev/null; echo "$?"`
    # newfile=`echo -n "${status}" 2> /dev/null | grep "new file:" &> /dev/null; echo "$?"`
    # renamed=`echo -n "${status}" 2> /dev/null | grep "renamed:" &> /dev/null; echo "$?"`
    # deleted=`echo -n "${status}" 2> /dev/null | grep "deleted:" &> /dev/null; echo "$?"`
    bits=''
    if [ "${unstagedchanges}" == "0" ]; then
        bits+="$(tput setaf 1)$(tput sgr0)"
    fi
    if [ "${stagedchanges}" == "0" ]; then
        bits+="$(tput setaf 2)$(tput sgr0)"
    fi
    if [ "${untracked}" == "0" ]; then
        bits+="$(tput setaf 1)$(tput sgr0)"
    fi
    if [ "${ahead}" == "0" ]; then
        bits+="$(tput setaf 4)$(tput sgr0)"
    fi
    if [ "${behind}" == "0" ]; then
        bits+="$(tput setaf 4)$(tput sgr0)"
    fi
    if [ "${diverged}" == "0" ]; then
        bits+="$(tput setaf 4)$(tput sgr0)"
    fi
    # if [ "${newfile}" == "0" ]; then
    #     bits="${bits}"
    # fi
    # if [ "${deleted}" == "0" ]; then
    #     bits="${bits}"
    # fi
    # if [ "${dirty}" == "0" ]; then
    #     bits="${bits}"
    # fi
    # if [ "${renamed}" == "0" ]; then
    #     bits="${bits}"
    # fi
    if [ ! "${bits}" == "" ]; then
        echo " ${bits}"
    else
        echo ""
    fi
}

export PS1="\n\[\e[34m\]╭\[\e[m\]\[\e[33m\]\t\[\e[m\] \w \`parse_git_branch\`\[\e[m\]\n\[\e[34m\]╰\[\e[m\]\\$ "

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alFh'
alias la='ls -Ah'
alias l='ls -CFh'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Tokens
# Since this file is committed to github, absolutely no tokens or
# other secrets can go in this file. Instead, they are added to a
# separate file which is not tracked by git.
if [ -f ~/.bash_secrets ]; then
    . ~/.bash_secrets
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

alias pbcopy='xclip -selection clipboard'
alias pbpaste='xclip -selection clipboard -o'

onetimeservice="https://onetime.lime.tech/"
function onetime() {
    curl -s -d password="$*" -d ttl=Week $onetimeservice | grep 'id="password-link"' | sed 's/.*\(https:[^"]*\).*".*/\1/' | xclip -selection clipboard
    echo 'Onetime URL copied to clipboard'
}
# function getonetime() {
#     url=`pbpaste`
#     if [[ "$url" =~ ^$onetimeservice ]]; then
#         curl -s $url | sed -e '1h;2,$H;$!d;g' -e 's/.*>\(.*\)<\/textarea>.*/\1/' | pbcopy
#     else
#         echo 'Error: Did not find a onetime URL in the clipboard'
#     fi
# }
