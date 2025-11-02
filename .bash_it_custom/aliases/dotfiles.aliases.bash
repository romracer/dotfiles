# shellcheck shell=bash
about-alias 'dotfiles config git repo alias'
url "https://www.atlassian.com/git/tutorials/dotfiles"

alias dotfiles='git --git-dir=$HOME/.cfg/ --work-tree=$HOME'
