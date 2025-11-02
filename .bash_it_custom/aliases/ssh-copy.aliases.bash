# shellcheck shell=bash
about-alias 'copy SSH keys to remote machine'

ssh-copy-key() {
  if [ -z "$1" ]; then
    echo "Usage: ssh-copy-key user@host"
    return 1
  fi
  
  ssh-copy-id "$1"
}
