# If not running interactively, don't do anything
[ -z "${PS1}" ] && return

# Source global configuration between bash and zsh
if [[ -f "${HOME}/.shrc" ]]; then
    source "${HOME}/.shrc"
fi

# Source global definitions
if [[ -f /etc/bashrc ]]; then
    source /etc/bashrc
fi

# Don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

PATH="${PATH}:/usr/share/shunit2"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="${PATH}:${HOME}/.rvm/bin"

[[ -s "${HOME}/.gvm/scripts/gvm" ]] && source "${HOME}/.gvm/scripts/gvm"
[[ -s "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"
