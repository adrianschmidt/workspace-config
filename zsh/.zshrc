export LANG=en_US.UTF-8

# --- START Prompt Configuration ---
# Update git_prompt and conda_prompt before showing each prompt
precmd() {
  git_prompt=$(get_git_prompt)
  conda_prompt=$(get_conda_env)

  # Dynamically build the PROMPT based on conda_prompt content
  if [[ -n $conda_prompt ]]; then
    PROMPT="${conda_prompt}
%F{magenta}╭ %f%F{yellow}%*%f %~ ${git_prompt}
%F{magenta}╰ %f%# "
  else
    PROMPT="%F{magenta}╭ %f%F{yellow}%*%f %~ ${git_prompt}
%F{magenta}╰ %f%# "
  fi
}

function get_git_prompt {
  local git_status=$(git status --porcelain=v2 --branch 2>&1)
  local branch=$(git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
  local detached=$(echo "$git_status" | grep '# branch.head (detached)')

  if [ -n "$detached" ]; then
    branch="%F{red}detached head%f"  # Indicate detached head state in red
  elif [ -n "$branch" ]; then
    branch="%F{green}$branch%f"  # Show branch name in green when on a branch
  fi

  if [ -n "$branch" ]; then
    local git_status=$(parse_git_dirty)
    # Check if git_status is not empty and prepend a space if it's not
    if [[ -n "$git_status" ]]; then
      git_status=" $git_status"
    fi
    echo "[$branch$git_status]"
  else
    echo ""  # Return an empty string if not in a git directory
  fi
}

function parse_git_dirty {
  local git_status=$(git status --porcelain=v2 --branch 2>&1)
  local bits=""

  bits+=$(parse_git_file_changes)

  bits+=$(parse_git_branch_status)

  echo $bits
}

function parse_git_file_changes {
  local git_status=$(git status --porcelain=v2 --branch 2>&1)
  local bits=""

  # Check if there are unstaged files (modified but not staged)
  if [[ $(echo "$git_status" | grep '^1 .M' ) != "" ]]; then
    bits+="%F{red}%f"
  fi
  # Check if there are staged files (modified and staged)
  if [[ $(echo "$git_status" | grep '^1 M.' ) != "" ]]; then
    bits+="%F{green}%f"
  fi
  # Check if there are staged new files (new and staged)
  if [[ $(echo "$git_status" | grep '^1 A.' ) != "" || $(echo "$git_status" | grep '^2 A.' ) != "" ]]; then
    bits+="%F{green}%f"
  fi
  # Check if there are untracked files
  if [[ $(echo "$git_status" | grep '^\?' ) != "" ]]; then
    bits+="%F{red}%f"
  fi

  echo $bits
}

function parse_git_branch_status {
  local git_status=$(git status --porcelain=v2 --branch 2>&1)
  local branch_ab_line=$(echo "$git_status" | grep '^# branch.ab ')

  if [[ -z "$branch_ab_line" ]]; then
    echo "" # Return nothing if not in a git directory or another error occurs
    return
  fi

  # Extracting ahead and behind directly from the +n -m format
  local ahead behind
  read ahead behind <<<$(echo "$branch_ab_line" | awk '{print substr($3,2), substr($4,2)}')

  # Ensure variables are treated as integers
  ((ahead+=0))
  ((behind+=0))

  if (( ahead == 0 && behind == 0 )); then
    echo "" # Branch is up-to-date
  elif (( ahead > 0 && behind > 0 )); then
    echo "%F{red}%f" # Branch has diverged
  elif (( ahead > 0 )); then
    echo "%F{blue}%f" # Branch is ahead
  elif (( behind > 0 )); then
    echo "%F{blue}%f" # Branch is behind
  fi
}
# --- END Prompt Configuration ---

# Tokens
# Since this file is committed to github, absolutely no tokens or
# other secrets can go in this file. Rather than using a separate file,
# the secrets are stored in the keychain and accessed via the `security`
# command line tool.
function with_githubtoken() {
  GITHUB_TOKEN=$( security find-generic-password -a adrianschmidt -s githubtoken -w ) $*
}
alias wgt=with_githubtoken
function with_githubtoken_mcp() {
  GITHUB_PERSONAL_ACCESS_TOKEN=$( security find-generic-password -a adrianschmidt -s githubMcpServerToken -w ) $*
}
function with_npmtoken() {
  NPM_TOKEN=$( security find-generic-password -a specularrain -s npmtoken -w ) $*
}
function with_openai_api_key() {
  OPENAI_API_KEY=$( security find-generic-password -a rubenpauladrian@gmail.com -s openai_api_token -w ) $*
}
function with_anthropic_api_key() {
  ANTHROPIC_API_KEY=$( security find-generic-password -a rubenpauladrian@gmail.com -s anthropic_api_token -w ) $*
}
function with_weblatetoken() {
  WEBLATE_TOKEN=$( security find-generic-password -a adrian.schmidt@lime.tech -s weblatetoken -w ) $*
}
function with_s3tokens() {
  AWS_ACCESS_KEY_ID=$( security find-generic-password -a none -s AWS_ACCESS_KEY_ID -w ) AWS_SECRET_ACCESS_KEY=$( security find-generic-password -a none -s AWS_SECRET_ACCESS_KEY -w ) $*
}
function with_bedrocktoken() {
  GITHUB_TOKEN=$( security find-generic-password -a adrian.schmidt -s awsbedrocktoken -w ) $*
}
function with_gemini_api_key() {
  GEMINI_API_KEY=$( security find-generic-password -a rubenpauladrian@gmail.com -s gemini_cli_api_key -w ) $*
}



# export PIP_REQUIRE_VIRTUALENV=true

cd() {
    builtin cd "$@"
    if [ -f .nvmrc ]; then
        nvm use;
        ~/update-node-symlink.sh
    fi
}

# --- BEGIN load alias definitions ---
# You may want to put all your additions into a separate file like
# ~/.zsh_aliases, instead of adding them here directly.

# Since pure aliases are compatible between bash and zsh, we can use the same
# file regardless of the shell. We load .bash_aliases first, just in case there
# are any overrides in .zsh_aliases.
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi
if [ -f ~/.zsh_aliases ]; then
    . ~/.zsh_aliases
fi
# --- END load alias definitions ---

# Functions are not as compatible between bash and zsh, so we keep those in
# separate files.
if [ -f ~/.zsh_functions ]; then
    . ~/.zsh_functions
fi

# Setup for `nvm` (node version manager)
export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Enable zsh's tab completion system
# Source: https://scriptingosx.com/2019/07/moving-to-zsh-part-5-completions/
autoload -Uz compinit && compinit
autoload -Uz bashcompinit && bashcompinit

# Autocomplete `cd ..` to `cd ../`
# Source: https://stackoverflow.com/a/716926/280972
zstyle ':completion:*' special-dirs true

# Load the homebrew command line tools
eval "$(/opt/homebrew/bin/brew shellenv)"

# Add the homebrew-installed git to the PATH
export PATH="/opt/homebrew/opt/git/bin:$PATH"

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
export PATH="/Users/adrian.schmidt/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)

# Created by `pipx` on 2024-02-22 07:45:30
export PATH="$PATH:/Users/adrian.schmidt/.local/bin"

export PIPX_HOME=~/.local/pipx

# To get Puppeteer to work, you need to install chromium manually by running
# `brew install chromium --no-quarantine`
# Since we install is manually, we need to tell Puppeteer to skip the download.
export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=true
export PUPPETEER_EXECUTABLE_PATH=`which chromium`

# Set up pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
fi
eval "$(pyenv init -)"

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/adrian.schmidt/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/adrian.schmidt/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/adrian.schmidt/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/adrian.schmidt/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup

# Deactivate the base conda environment
conda deactivate
# <<< conda initialize <<<

# Function to get the current active conda environment name
get_conda_env() {
  # Uses `jq`. Install with `brew install jq` or `sudo apt-get install jq`
  # local env_name=$(conda info --envs --json | jq -r '.active_prefix_name // empty')
  # if [[ -n $env_name ]]; then
  #   echo "($env_name)"
  # fi
}
test -e /Users/adrian.schmidt/.iterm2_shell_integration.zsh && source /Users/adrian.schmidt/.iterm2_shell_integration.zsh || true

export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"
