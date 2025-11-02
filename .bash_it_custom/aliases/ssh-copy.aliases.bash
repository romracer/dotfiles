# shellcheck shell=bash
about-alias 'copy SSH keys to remote machine'

ssh-copy-key() {
  if [ -z "$1" ]; then
    echo "Usage: ssh-copy-key user@host"
    return 1
  fi

  # Check if SSH keys exist
  if ! ls ~/.ssh/id_* >/dev/null 2>&1; then
    echo "Error: No SSH keys found in ~/.ssh/"
    return 1
  fi

  # Copy SSH keys (both public and private) to remote machine
  # This allows the remote machine to use these keys for authentication to third parties
  ssh "$1" "mkdir -p ~/.ssh && chmod 700 ~/.ssh" || return 1
  scp -r ~/.ssh/id_* "$1:~/.ssh/" || return 1
  ssh "$1" "chmod 600 ~/.ssh/id_* 2>/dev/null; chmod 644 ~/.ssh/id_*.pub 2>/dev/null; true"
}
