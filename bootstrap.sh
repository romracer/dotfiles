#!/usr/bin/env bash
# dotfiles installer

set -euo pipefail

command_exists() {
  command -v "$1" > /dev/null 2>&1
}

dotfiles() {
   git --git-dir=$HOME/.cfg/ --work-tree=$HOME $@
}

if ! command_exists git; then
  echo "ERROR: git not found. dotfiles setup requires git."
  exit 1
fi

if [ ! -d "$HOME/.bash_it" ]; then
  git clone --depth=1 https://github.com/Bash-it/bash-it.git $HOME/.bash_it
  chmod +x $HOME/.bash_it/install.sh
  $HOME/.bash_it/install.sh -n
fi

if [ ! -d "$HOME/.cfg" ]; then
  if command_exists ssh-keyscan; then
    ssh-keyscan -t rsa,ecdsa,ed25519 github.com >> ~/.ssh/known_hosts
  fi
  git clone --bare git@github.com:romracer/dotfiles.git $HOME/.cfg

  mkdir -p .config-backup
  set +e
  dotfiles checkout

  if [ $? = 0 ]; then
    echo "OK: checked out dotfiles config."
  else
    echo "WARN: backing up pre-existing dotfiles."
    dotfiles checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | xargs -I{} mv {} .config-backup/{}

    dotfiles checkout
    if [ $? = 0 ]; then
      echo "OK: checked out dotfiles config."
    else
      echo "ERROR: error checking out dotfiles config."
      exit 1
    fi
  fi
  set -e

  dotfiles config status.showUntrackedFiles no
fi
