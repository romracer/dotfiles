# shellcheck shell=bash
about-alias 'copy SSH keys to remote machine'

ssh-copy-keys() {
  if [ -z "$1" ]; then
    echo "Usage: ssh-copy-keys user@host"
    return 1
  fi

  # Check if SSH keys exist
  if ! ls ~/.ssh/id_* >/dev/null 2>&1; then
    echo "Error: No SSH keys found in ~/.ssh/"
    return 1
  fi

  # Copy SSH keys (both public and private) to remote machine
  # This allows the remote machine to use these keys for authentication to third parties
  # Using a single SSH command to avoid multiple authentication prompts
  {
    echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    for keyfile in ~/.ssh/id_*; do
      if [ -f "$keyfile" ]; then
        filename=$(basename "$keyfile")
        echo "cat > ~/.ssh/$filename << 'EOF_SSH_KEY'"
        cat "$keyfile"
        echo "EOF_SSH_KEY"
        if [[ "$keyfile" == *.pub ]]; then
          echo "chmod 644 ~/.ssh/$filename"
        else
          echo "chmod 600 ~/.ssh/$filename"
        fi
      fi
    done
  } | ssh "$1" "sh -s"
}
