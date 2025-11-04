#!/usr/bin/env bash
# dotfiles installer

set -euo pipefail

command_exists() {
  command -v "$1" > /dev/null 2>&1
}

dotfiles() {
  git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

faketty () {
  script -qefc "$(printf "%q " "$@")" /dev/null
}
 
BASH_IT_REPO="https://github.com/Bash-it/bash-it.git"
DOTFILES_REPO="https://github.com/romracer/dotfiles.git"

if ! command_exists git; then
  echo "ERROR: git not found. dotfiles setup requires git."
  exit 1
fi

if ! command_exists curl; then
  echo "ERROR: curl not found. dotfiles setup requires curl."
  exit 1
fi

if ! command_exists jq; then
  echo "INFO: jq not found. installing jq via webi."
  curl -sS https://webi.sh/jq | sh; \
  source $HOME/.config/envman/PATH.env
fi

if [ ! -d "$HOME/.cfg" ]; then
  ssh-keygen -F github.com || ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> $HOME/.ssh/known_hosts
  git clone --bare --single-branch $DOTFILES_REPO $HOME/.cfg

  mkdir -p $HOME/.config-backup
  set +e
  dotfiles checkout

  if [ $? = 0 ]; then
    echo "OK: checked out dotfiles config."
  else
    echo "WARN: backing up pre-existing dotfiles."
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} $HOME/.config-backup/{}
    dotfiles checkout -f

    if [ $? = 0 ]; then
      echo "OK: checked out dotfiles config."
    else
      echo "ERROR: error checking out dotfiles config."
      exit 1
    fi
  fi
  set -e

  dotfiles config status.showUntrackedFiles no
  dotfiles config --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
fi

if ! command_exists gh; then
  echo "INFO: GitHub CLI (gh) not found. installing gh via webi."
  curl -sS https://webi.sh/gh | sh; \
  source $HOME/.config/envman/PATH.env
fi

if [ ! -d "$HOME/.bash_it" ]; then
  git clone --depth=1 $BASH_IT_REPO $HOME/.bash_it
  chmod +x $HOME/.bash_it/install.sh
  $HOME/.bash_it/install.sh -n
  ln -sf "$HOME/.bash_it_custom/profiles/my_profile.bash_it" "$HOME/.bash_it/profiles/"
  ln -sf "$HOME/.bash_it_custom/profiles/work_profile.bash_it" "$HOME/.bash_it/profiles/"
  faketty bash -ic "bash-it profile load my_profile"
fi

if [ $(whoami) = "coder" ]; then
  echo "INFO: running as coder user."

  if [ ! -s $HOME/.ssh/git-commit-signing/coder ] || [ ! -s $HOME/.ssh/git-commit-signing/coder.pub ]; then
    if [ -n "${CODER_AGENT_URL:-}" ] && [ -n "${CODER_AGENT_TOKEN:-}" ]; then
      mkdir -p $HOME/.ssh/git-commit-signing
      chmod 700 $HOME/.ssh && chmod 700 $HOME/.ssh/git-commit-signing

      ssh_key=$(curl --request GET \
        --url "${CODER_AGENT_URL}api/v2/workspaceagents/me/gitsshkey" \
        --header "Coder-Session-Token: ${CODER_AGENT_TOKEN}" \
        --silent --show-error)

      jq --raw-output ".public_key" > $HOME/.ssh/git-commit-signing/coder.pub <<< $ssh_key
      jq --raw-output ".private_key" > $HOME/.ssh/git-commit-signing/coder <<< $ssh_key

      chmod 600 $HOME/.ssh/git-commit-signing/coder
      chmod 644 $HOME/.ssh/git-commit-signing/coder.pub

      faketty bash -ic "ssh-add $HOME/.ssh/git-commit-signing/coder"
    else
      echo "WARN: CODER_AGENT_URL or CODER_AGENT_TOKEN not set. skipping git commit signing setup."
    fi
  else
    faketty bash -ic "ssh-add $HOME/.ssh/git-commit-signing/coder"
  fi
fi
