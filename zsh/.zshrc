# Source global configuration between bash and zsh
if [[ -f "${HOME}/.shrc" ]]; then
    source "${HOME}/.shrc"
fi

# Path to the oh-my-zsh installation.
# Standard installation
if [[ -d "${HOME}/.oh-my-zsh" ]]; then
    export ZSH="${HOME}/.oh-my-zsh"
else
    # ArchLinux oh-my-zsh-git package
    export ZSH="/usr/share/oh-my-zsh"
fi

ZSH_THEME='gnzh'

# Use hyphen-insensitive completion.
# Case sensitive completion must be off. _ and - will be interchangeable.
HYPHEN_INSENSITIVE="true"
# Disable bi-weekly auto-update checks.
DISABLE_AUTO_UPDATE='true'
# Disable marking untracked files under VCS as dirty.
# This makes repository status check for large repositories much, much faster.
DISABLE_UNTRACKED_FILES_DIRTY="true"
# Change the command execution time stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

plugins=(git mercurial bundler osx brew gem)

source "${ZSH}/oh-my-zsh.sh"

# User configuration

export MANPATH="/usr/local/man:${MANPATH}"

# Preferred editor for local and remote sessions
if [[ -n "${SSH_CONNECTION}" ]]; then
  export EDITOR='vim'
else
  export EDITOR='gvim'
fi

# Compilation flags
export ARCHFLAGS="-arch x86_64"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="${PATH}:${HOME}/.rvm/bin"

[[ -s "${HOME}/.gvm/scripts/gvm" ]] && source "${HOME}/.gvm/scripts/gvm"
[[ -s "${HOME}/.cargo/env" ]] && source "${HOME}/.cargo/env"
