# shellcheck shell=bash
about-alias 'copy SSH keys to remote machine'

ssh-copy-keys() {
  if [ -z "$1" ]; then
    echo "Usage: ssh-copy-keys user@host"
    return 1
  fi

  # Check if .ssh directory exists
  if [ ! -d ~/.ssh ]; then
    echo "Error: ~/.ssh/ directory not found"
    return 1
  fi

  # Find all SSH keys (private and public) using grep
  # Private keys contain "PRIVATE KEY", public keys start with "ssh-" or "ecdsa-"
  # Exclude common non-key files like authorized_keys, known_hosts, config
  local keyfiles
  keyfiles=$(find ~/.ssh -type f \
    ! -name "authorized_keys" \
    ! -name "known_hosts" \
    ! -name "config" \
    ! -name "environment" \
    \( -exec grep -lE "PRIVATE KEY" {} \; -o -exec grep -lE "^(ssh-|ecdsa-)" {} \; \) 2>/dev/null | sort -u)

  if [ -z "$keyfiles" ]; then
    echo "Error: No SSH keys found in ~/.ssh/"
    return 1
  fi

  # Copy SSH keys (both public and private) to remote machine
  # This allows the remote machine to use these keys for authentication to third parties
  # Using a single SSH command to avoid multiple authentication prompts
  {
    echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    echo "$keyfiles" | while IFS= read -r keyfile; do
      if [ -f "$keyfile" ]; then
        filename=$(basename "$keyfile")
        # Use base64 encoding to safely transfer binary/text content
        echo "base64 -d > ~/.ssh/$filename << 'EOF_B64_KEY'"
        base64 < "$keyfile"
        echo "EOF_B64_KEY"
        case "$filename" in
          *.pub)
            echo "chmod 644 ~/.ssh/$filename"
            ;;
          *)
            echo "chmod 600 ~/.ssh/$filename"
            ;;
        esac
      fi
    done
  } | ssh "$1" "sh -s"
}
