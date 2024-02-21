
# --- START Prompt Configuration ---
# Define a variable to hold the dynamic part of the prompt
git_prompt=""

# Update git_prompt before showing each prompt
precmd() {
  git_prompt=$(get_git_prompt)

  # Set the PROMPT with a reference to the git_prompt variable
  PROMPT="%F{magenta}╭ %f%F{yellow}%*%f %~ ${git_prompt}
%F{magenta}╰ %f%# "
}

function get_git_prompt {
  local branch=$(git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
  if [ -n "$branch" ]; then
    local git_status=$(parse_git_dirty)
    # Check if git_status is not empty and prepend a space if it's not
    if [[ -n "$git_status" ]]; then
      git_status=" $git_status"
    fi
    echo "[%F{green}$branch%f$git_status]"
  else
    echo ""
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

  # Check if there are unstaged files
  if [[ $(echo "$git_status" | grep '^1 .M' ) != "" ]]; then
    bits+="%F{red}%f"
  fi
  # Check if there are staged files
  if [[ $(echo "$git_status" | grep '^1 M.' ) != "" ]]; then
    bits+="%F{green}%f"
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
function with_weblatetoken() {
  WEBLATE_TOKEN=$( security find-generic-password -a adrian.schmidt@lime.tech -s weblatetoken -w ) $*
}
function with_openai_api_key() {
  OPENAI_API_KEY=$( security find-generic-password -a rubenpauladrian@gmail.com -s openai_api_token -w ) $*
}

export PIP_REQUIRE_VIRTUALENV=true

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
