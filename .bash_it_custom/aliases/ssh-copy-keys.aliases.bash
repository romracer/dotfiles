# shellcheck shell=bash
about-alias 'copy SSH keys to remote machine'

ssh-copy-keys() {
  if [ -z "$1" ]; then
    echo "Usage: ssh-copy-keys user@host [keyname]"
    return 1
  fi

  # Check if .ssh directory exists
  if [ ! -d ~/.ssh ]; then
    echo "Error: ~/.ssh/ directory not found"
    return 1
  fi

  local key_filter="$2"
  local key_filter_escaped=""
  
  # Strip .pub extension if present, since we want to match both private and public keys
  # Escape special regex characters in key_filter to prevent regex injection
  if [ -n "$key_filter" ]; then
    local key_filter_base="${key_filter%.pub}"
    key_filter_escaped=$(printf '%s\n' "$key_filter_base" | sed 's/[][\\.|$(){}?+*^-]/\\&/g')
  fi
  
  # Find all SSH keys (private and public) using grep
  # Private keys contain "PRIVATE KEY", public keys start with specific key type identifiers
  # Exclude common non-key files like authorized_keys, known_hosts, config
  local keyfiles
  keyfiles=$({
    find ~/.ssh -type f \
      ! -name "authorized_keys" \
      ! -name "known_hosts" \
      ! -name "config" \
      ! -name "environment" \
      -exec grep -lE "PRIVATE KEY" {} \;
    find ~/.ssh -type f \
      ! -name "authorized_keys" \
      ! -name "known_hosts" \
      ! -name "config" \
      ! -name "environment" \
      -exec grep -lE "^(ssh-rsa|ssh-dss|ssh-ed25519|ecdsa-sha2-)" {} \;
  } 2>/dev/null | sort -u)
  
  # Filter by key filename if provided
  if [ -n "$key_filter_escaped" ]; then
    keyfiles=$(printf '%s\n' "$keyfiles" | grep -E "(^|/)${key_filter_escaped}(\.pub)?$")
  fi

  if [ -z "$keyfiles" ]; then
    if [ -n "$key_filter" ]; then
      echo "Error: No SSH keys matching '$key_filter' found in ~/.ssh/"
    else
      echo "Error: No SSH keys found in ~/.ssh/"
    fi
    return 1
  fi

  # Copy SSH keys (both public and private) to remote machine
  # This allows the remote machine to use these keys for authentication to third parties
  # Using a single SSH command to avoid multiple authentication prompts
  {
    echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh"
    printf '%s\n' "$keyfiles" | while IFS= read -r keyfile; do
      if [ -f "$keyfile" ]; then
        # Preserve subdirectory structure by getting relative path from ~/.ssh/
        relative_path="${keyfile#"$HOME"/.ssh/}"
        # Create subdirectory on remote host if needed
        keydir=$(dirname "$relative_path")
        if [ "$keydir" != "." ]; then
          echo "mkdir -p ~/.ssh/$keydir && chmod 700 ~/.ssh/$keydir"
        fi
        # Use base64 encoding to safely transfer binary/text content
        echo "base64 -d > ~/.ssh/$relative_path << 'EOF_B64_KEY'"
        base64 < "$keyfile"
        echo "EOF_B64_KEY"
        case "$relative_path" in
          *.pub)
            echo "chmod 644 ~/.ssh/$relative_path"
            ;;
          *)
            echo "chmod 600 ~/.ssh/$relative_path"
            ;;
        esac
      fi
    done
  } | ssh "$1" "sh -s"
  
  # Output each key that was copied
  echo "Copied SSH keys:"
  printf '%s\n' "$keyfiles" | while IFS= read -r keyfile; do
    if [ -f "$keyfile" ]; then
      relative_path="${keyfile#"$HOME"/.ssh/}"
      echo "  ~/.ssh/$relative_path"
    fi
  done
}
