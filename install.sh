#!/usr/bin/env bash

# Let's create the ~/.dotfiles folder to store cloned dotfiles
echo $HOME
mkdir ~/.dotfiles
cd ~/.dotfiles
git clone https://github.com/andreffs18/dotfiles .

# Now let's symlinc all our dotfiles to the direcotry where they are expected (usually, our home directory) 
ln -sv ~/.dotfiles/.bashrc ~
ln -sv ~/.dotfiles/.logging ~
ln -sv ~/.dotfiles/.bash_profile ~
ln -sv ~/.dotfiles/.exports ~
ln -sv ~/.dotfiles/.aliases ~
ln -sv ~/.dotfiles/.functions ~
ln -sv ~/.dotfiles/.dircolor ~
ln -sv ~/.dotfiles/.inputrc ~
ln -sv ~/.dotfiles/.osx ~
ln -sv ~/.dotfiles/.prompt ~
ln -sv ~/.dotfiles/.mansettings ~
ln -sv ~/.dotfiles/.olhaaqui ~

# Symlink all git configuration files
ln -sv ~/.dotfiles/config/git/.gitignore ~
ln -sv ~/.dotfiles/config/git/.gitconfig ~
# Symlink python linting flake8 configuration
ln -sv ~/.dotfiles/config/python/flake8 ~/.config/flake8

# Setup MacOS settings for the first time
source ~/.osx

# Apply settings to all terminal sessions without need of a restart
source ~/.bashrc

# Install brew and brew cast applications
log.info "Loading Brewfile ..."
brew bundle --file=/install/Brewfile

log.info "Loading Castfile ..."
brew bundle --file=/install/Castfile
