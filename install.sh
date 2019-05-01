#!/usr/bin/env bash

DIRECTORY="~/.dotfiles"

# Let's create the ~/.dotfiles folder to store cloned dotfiles
if [ -d "$DIRECTORY" ]; then
  cd ~/.dotfiles
  git pull origin master
else
  mkdir ~/.dotfiles
  cd ~/.dotfiles
  git clone https://github.com/andreffs18/dotfiles .
fi

# Now let's symlinc all our dotfiles to the direcotry where they are expected (usually, our home directory) 
ln -sfv ~/.dotfiles/.bash_profile ~
ln -sfv ~/.dotfiles/.bashrc ~
ln -sfv ~/.dotfiles/.logging ~
ln -sfv ~/.dotfiles/.exports ~
ln -sfv ~/.dotfiles/.aliases ~
ln -sfv ~/.dotfiles/.functions ~
ln -sfv ~/.dotfiles/.inputrc ~
ln -sfv ~/.dotfiles/.prompt ~
ln -sfv ~/.dotfiles/.mansettings ~
ln -sfv ~/.dotfiles/.olhaaqui ~

# Symlink MacOS initial configuration
ln -sfv ~/.dotfiles/config/mac/.osx ~
# Symlink all git configuration files
ln -sfv ~/.dotfiles/config/git/.gitignore_global ~
ln -sfv ~/.dotfiles/config/git/.gitconfig ~

# Symlink python linting flake8 configuration 
if [ ! -d ~/.config/ ]; then
  mkdir ~/.config/;
fi
ln -sfv ~/.dotfiles/config/python/flake8 ~/.config/flake8

# Initialize Logging
source ~/.logging

# Setup MacOS settings for the first time
source ~/.osx

# Apply settings to all terminal sessions without need of a restart
source ~/.bashrc

# Install brew and brew cast applications
log.info "Loading Brewfile ..."
brew bundle --file=~/.dotfiles/install/Brewfile

log.info "Loading Castfile ..."
brew bundle --file=~/.dotfiles/install/Castfile
