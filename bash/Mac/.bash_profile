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

export PS1="\n\[\e[35m\]╭ \[\e[m\]\[\e[33m\]\t\[\e[m\] \w \`parse_git_branch\`\[\e[m\]\n\[\e[35m\]╰ \[\e[m\]\\$ "

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# Tokens
# Since this file is committed to github, absolutely no tokens or
# other secrets can go in this file. Instead, they are added to a
# separate file which is not tracked by git.

if [ -f ~/.bash_secrets ]; then
    . ~/.bash_secrets
fi
