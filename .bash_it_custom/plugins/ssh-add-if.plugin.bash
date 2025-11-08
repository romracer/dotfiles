# shellcheck shell=bash
cite about-plugin
about-plugin 'only load SSH key in agent if unloaded'
url "https://labs.underpants-gnomes.biz/"

ssh-add-if() {
  about 'load keys only if unloaded'
  param '1: private key filename'
  group 'ssh'

  if [ -z "$1" ]; then
    echo "Usage: ssh-add-if filename"
    return 1
  fi

  # Check if private key file exists
  if [ ! -s "$1" ]; then
    echo "Error: $1 not found or empty"
    return 1
  fi

  # Only add key if not already loaded
  if ! ssh-add -L 2>/dev/null | ssh-keygen -lf /dev/stdin 2>/dev/null | grep -q "$(ssh-keygen -lf "$1" 2>/dev/null | awk '{print $2}')"; then
    ssh-add "$KEY_PATH"
  fi
}
