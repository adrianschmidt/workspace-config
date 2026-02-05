# Install with `brew install bash-completion`
[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

# enable recursive globbing
# shopt -s globstar

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
        bits+="$(tput setaf 1)$(tput sgr0)"
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

# Tokens
# Since this file is committed to github, absolutely no tokens or
# other secrets can go in this file. Rather than using a separate file,
# the secrets are stored in the keychain and accessed via the `security`
# command line tool.
function with_githubtoken() {
    GITHUB_TOKEN=$( security find-generic-password -a adrianschmidt -s githubtoken -w ) $*
}
function with_weblatetoken() {
    WEBLATE_TOKEN=$( security find-generic-password -a adrian.schmidt@lime.tech -s weblatetoken -w ) $*
}
function with_openai_api_key() {
    OPENAI_API_KEY=$( security find-generic-password -a rubenpauladrian@gmail.com -s openai_api_token -w ) $*
}

export PIP_REQUIRE_VIRTUALENV=true

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.bash_functions ]; then
    . ~/.bash_functions
fi

test -e "${HOME}/.iterm2_shell_integration.bash" && source "${HOME}/.iterm2_shell_integration.bash"

export BASH_SILENCE_DEPRECATION_WARNING=1

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('~/anaconda3/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "~/anaconda3/etc/profile.d/conda.sh" ]; then
        . "~/anaconda3/etc/profile.d/conda.sh"
    else
        export PATH="~/anaconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

conda deactivate

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Created by `pipx` on 2021-08-18 07:29:09
export PATH="$PATH:~/.local/bin"

# export PATH="$HOME/.poetry/bin:$PATH"

# Setup for `nvm` (node version manager)
export NVM_DIR="$HOME/.nvm"
  [ -s "/usr/local/opt/nvm/nvm.sh" ] && \. "/usr/local/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/usr/local/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/usr/local/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

source ~/.docker/init-bash.sh || true # Added by Docker Desktop
