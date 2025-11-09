# shellcheck shell=bash
# shellcheck disable=SC2034

# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return ;;
esac

# Path to the bash it configuration
BASH_IT="${HOME}/.bash_it"

# Lock and Load a custom theme file.
# Leave empty to disable theming.
# location "$BASH_IT"/themes/
export BASH_IT_THEME='powerline-plain'

# Some themes can show whether `sudo` has a current token or not.
# Set `$THEME_CHECK_SUDO` to `true` to check every prompt:
THEME_CHECK_SUDO='false'

# (Advanced): Change this to the name of your remote repo if you
# cloned bash-it with a remote other than origin such as `bash-it`.
#BASH_IT_REMOTE='bash-it'

# (Advanced): Change this to the name of the main development branch if
# you renamed it or if it was changed for some reason
#BASH_IT_DEVELOPMENT_BRANCH='master'

# Your place for hosting Git repos. I use this for private repos.
#GIT_HOSTING='git@git.domain.com'

# Don't check mail when opening terminal.
unset MAILCHECK

# Change this to your console based IRC client of choice.
export IRC_CLIENT='irssi'

# Set this to the command you use for todo.txt-cli
TODO="t"

# Set this to the location of your work or project folders
#BASH_IT_PROJECT_PATHS="${HOME}/Projects:/Volumes/work/src"

# Set this to false to turn off version control status checking within the prompt for all themes
SCM_CHECK=true

# Set to actual location of gitstatus directory if installed
SCM_GIT_GITSTATUS_DIR="$HOME/.gitstatus"
# per default gitstatus uses 2 times as many threads as CPU cores, you can change this here if you must
export GITSTATUS_NUM_THREADS=8

# If your theme use command duration, uncomment this to
# enable display of last command duration.
#BASH_IT_COMMAND_DURATION=true
# You can choose the minimum time in seconds before
# command duration is displayed.
#COMMAND_DURATION_MIN_SECONDS=1

# Set Xterm/screen/Tmux title with shortened command and directory.
# Uncomment this to set.
SHORT_TERM_LINE=true

# Set vcprompt executable path for scm advance info in prompt (demula theme)
# https://github.com/djl/vcprompt
#VCPROMPT_EXECUTABLE=~/.vcprompt/bin/vcprompt

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# after enabling or disabling aliases, plugins, and completions.
#BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload.
#BASH_IT_RELOAD_LEGACY=1

# Custom Bash It content location
BASH_IT_CUSTOM="${HOME}/.bash_it_custom"

# Custom Bash It variables
COMMAND_DURATION_PROMPT_COLOR=${POWERLINE_COMMAND_DURATION_COLOR:=129}
POWERLINE_PROMPT="user_info hostname scm k8s_context k8s_namespace cwd last_status"

# Load Bash It
[ -s "${BASH_IT?}/bash_it.sh" ] && source "${BASH_IT?}/bash_it.sh"

# Generated for envman. Do not edit.
[ -s "$HOME/.config/envman/load.sh" ] && source "$HOME/.config/envman/load.sh"

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# don't save common commands in history
HISTIGNORE="ls:exit:cd ..:cd:cd -:ps auxwwf:w"

# load git commit signing key if it exists and is not already loaded
KEY_PATH="$HOME/.ssh/git-commit-signing/coder"
KEY_PUB="$HOME/.ssh/git-commit-signing/coder.pub"
if [ -s "$KEY_PATH" ] && [ -s "$KEY_PUB" ]; then
    chmod 700 "$HOME/.ssh" && chmod 700 "$HOME/.ssh/git-commit-signing"
    chmod 600 "$KEY_PATH"
    chmod 644 "$KEY_PUB"

    ssh-add-if "$KEY_PATH"
fi

# load autoenv .env in home directory
AUTOENV_AUTH_FILE=$HOME/.autoenv_authorized
AUTOENV_NOTAUTH_FILE=$HOME/.autoenv_not_authorized
AUTOENV_ENABLE_LEAVE=
AUTOENV_VIEWER=cat
[ -s "$HOME/.autoenv/activate.sh" ] && source "$HOME/.autoenv/activate.sh"
cd $HOME
