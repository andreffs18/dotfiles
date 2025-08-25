#!/usr/bin/env bash
# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

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
# HIST_STAMPS="mm/dd/yyyy"

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

autoload -U compinit && compinit

source $ZSH/oh-my-zsh.sh

##############################################################
# User configuration
##############################################################

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
source ~/.bash_profile

# This speeds up pasting w/ autosuggest
# source: https://github.com/zsh-users/zsh-autosuggestions/issues/238
pasteinit() {
  OLD_SELF_INSERT=${${(s.:.)widgets[self-insert]}[2,3]}
  zle -N self-insert url-quote-magic
}
pastefinish() {
  zle -N self-insert $OLD_SELF_INSERT
}
zstyle :bracketed-paste-magic paste-init pasteinit
zstyle :bracketed-paste-magic paste-finish pastefinish

# Pure Prompt Configuration
# more can be found here: https://github.com/sindresorhus/pure#getting-started
autoload -U promptinit; promptinit
# optionally define some options
PURE_CMD_MAX_EXEC_TIME=10
# change the path color
zstyle :prompt:pure:path color white
# change the color for both  and
zstyle :prompt:pure:prompt:success color green
zstyle :prompt:pure:prompt:error color red
prompt pure

# Add kube cluster and namespace context to prompt
source "/usr/local/opt/kube-ps1/share/kube-ps1.sh"
PROMPT='$(kube_ps1) '$PROMPT

# Source Unbabel Secrets
source ~/.unbabel

# Source My Secrets
source ~/.secrets

# # Reset PATH
# export PATH="/Users/andresilva/.cargo/bin:\
# /Users/andresilva/.local/bin:\
# /Users/andresilva/.nvm/versions/node/v12.4.0/bin:\
# /Users/andresilva/.rbenv/versions/3.1.2/bin:\
# /Users/andresilva/bin:\
# /Users/andresilva/.rd/bin:\
# /usr/local/bin:\
# /usr/bin:\
# /usr/sbin:\
# /bin:\
# /sbin:\
# /opt/homebrew/bin:\
# /opt/homebrew/sbin"


# # GO PATH
# export GOROOT=/usr/local/go
# export GOPATH=$HOME/go
# export GOBIN=$GOPATH/bin
# export PATH="$PATH:$GOROOT:$GOPATH:$GOBIN:/usr/local/go/bin/"

# alias docker-stop-all="docker stop $(docker ps -a -q)"
# alias clean-rancher="sudo rm -rf ~/Library/Application\ Support/rancher-desktop/lima"
# Make sure my varrun docker.sock is symlined to /var/run/docker.sock
# sudo ln -s -f $HOME/.rd/docker.sock /var/run/docker.sock

# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# docker builder prune
# docker image prune --all --force
# docker volume prune --all --force
# docker system prune -a --volumes

# sfl &

# . "$HOME/.local/bin/env"

# alias makemehappy='docker builder prune && echo "builder prune done" && docker image prune --all --force && echo "image prune done" &&  docker volume prune --all --force && echo "volume prune done" && docker system prune --all --volumes && echo "system prune done"'
# alias arm="env arch -arm64 /bin/zsh --login"
# alias intel="env arch -x86_64 /bin/zsh --login"



# export PATH="$HOME/.pyenv/bin:$PATH"
# eval "$(pyenv init -)"

# . /usr/local/opt/asdf/libexec/asdf.sh
# . "$HOME/.local/bin/env"
# . "$HOME/.cargo/env"

# If you need to have libpq first in your PATH, run:
# export PATH="/usr/local/opt/libpq/bin:$PATH"

# For compilers to find libpq you may need to set:
# export LDFLAGS="-L/usr/local/opt/libpq/lib"
# export CPPFLAGS="-I/usr/local/opt/libpq/include"

# For pkg-config to find libpq you may need to set:
# export PKG_CONFIG_PATH="/usr/local/opt/libpq/lib/pkgconfig"


# So that Roocline can work with VSCode
# Source: https://docs.roocode.com/troubleshooting/shell-integration/#installation-instructions
# [[ "$TERM_PROGRAM" == "vscode" ]] && . "$(vs --locate-shell-integration-path zsh)"

# . /usr/local/opt/asdf/libexec/asdf.sh

# # Set JAVA_HOME for JDK 21
# export JAVA_HOME=/usr/local/Cellar/openjdk@21/21.0.7/libexec/openjdk.jdk/Contents/Home
# export PATH="$JAVA_HOME/bin:$PATH"
# export COMPOSE_BAKE=true

### MANAGED BY RANCHER DESKTOP START (DO NOT EDIT)
# export PATH="/Users/andresilva/.rd/bin:$PATH"
### MANAGED BY RANCHER DESKTOP END (DO NOT EDIT)
