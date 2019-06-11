#!/usr/bin/env bash

# Install brew package manager
if test ! $(which brew); then
  echo | /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
else
  echo "Ruby already installed: \"$(ruby -v)\""
fi

# Update any recipes
brew update

log.info "##### Installing all Brewfile dependencies #####"
brew bundle --file=$DIRECTORY/install/Brewfile
log.info "##### Installing all Caskfile dependencies #####"
brew bundle --file=$DIRECTORY/install/Caskfile
log.info "##### Installing all Masfile dependencies #####"
brew bundle --file=$DIRECTORY/install/Masfile

log.info "Setup packages:"

log.info "$ zsh --version"
log.success "$(zsh --version)"
source $DIRECTORY/config/mac/zsh

log.info "$ dockutil --version" 
log.success "$(dockutil --version)"
source $DIRECTORY/config/mac/dockutil

# Remove brew and cask old formulas
brew cleanup
brew cask cleanup

# Reminder to install missing apps
log.warning "Don't forget to install the following:\n˲ Exodus: https://www.exodus.io/download/\n˲ Final Cut Pro\n˲ Microsoft Excel/Word"
