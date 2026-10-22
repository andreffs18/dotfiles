# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH
# Path to your oh-my-zsh installation.
export ZSH=/Users/$USER/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# Turn of zsh theme so Pure Prompt can run
# ZSH_THEME="robbyrussell"
# ZSH_THEME="amuse"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
HIST_STAMPS="yyyy-mm-dd"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
# plugins=(git colored-man colorize pip python brew osx zsh-syntax-highlighting)
plugins=(
    git
    zsh-syntax-highlighting
    zsh-autosuggestions
    zsh-completions
)
source $ZSH/oh-my-zsh.sh

autoload -U compinit && compinit

# Pure Prompt Configuration
# more can be found here: https://github.com/sindresorhus/pure#getting-started
autoload -U promptinit; promptinit
# change the path color; change the color for both 'prompt:success' and 'prompt:error'
zstyle :prompt:pure:path color white
zstyle :prompt:pure:prompt:success color green
zstyle :prompt:pure:prompt:error color red

prompt pure

# Add kube cluster and namespace context to prompt
source "/usr/local/share/kube-ps1.sh"
PROMPT='$(kube_ps1) '$PROMPT

source ~/.bash_profile
source $DIRECTORY/config/apps/speed-pasting-zsh.sh

. "$HOME/.local/bin/env"

export PATH="$HOME/.rd/bin:$PATH"
# Make sure my var run docker.sock is symlinked to /var/run/docker.sock
# sudo ln -s -f $HOME/.rd/docker.sock /var/run/docker.sock

export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

nvm() { unset -f nvm; [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"; nvm "$@"; }
node() { unset -f node; [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"; node "$@"; }

# Suppress the "Last login:" line macOS prints on every new terminal session.
# ~/.hushlogin just needs to exist — its presence is the signal to the OS to stay quiet.
[[ -f ~/.hushlogin ]] || touch ~/.hushlogin

#################### Custom user settings ####################
source ~/.unbabelconfigs/utils.sh
# Source My Secrets
source ~/.secrets

# Welcome message
olhaaqui

sfl
