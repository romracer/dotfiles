# shellcheck shell=bash
about-alias 'copy SSH keys to remote machine'

ssh-copy-key() {
  if [ -z "$1" ]; then
    echo "Usage: ssh-copy-key user@host"
    return 1
  fi

  # Copy SSH keys (both public and private) to remote machine
  # This allows the remote machine to use these keys for authentication to third parties
  ssh "$1" "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
  scp -r ~/.ssh/id_* "$1:~/.ssh/"
  ssh "$1" "chmod 600 ~/.ssh/id_* && chmod 644 ~/.ssh/id_*.pub 2>/dev/null || true"
}
