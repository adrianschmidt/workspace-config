
# Tokens
# Since this file is committed to github, absolutely no tokens or
# other secrets can go in this file. Instead, they are added to a
# separate file which is not tracked by git.
if [ -f ~/.zsh_secrets ]; then
    . ~/.zsh_secrets
fi

if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi

# Created by `userpath` on 2020-09-29 13:23:09
export PATH="$PATH:/Users/ads/.local/bin"

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
