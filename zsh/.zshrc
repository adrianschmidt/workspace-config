
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
