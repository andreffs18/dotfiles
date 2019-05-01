#!/usr/bin/env bash

# Let's create the ~/.dotfiles folder to store cloned dotfiles
mkdir ~/.dotfiles
cd ~/.dotfiles
git clone https://github.com/mathiasbynens/dotfiles.git .
# Now let's symlinc all our dotfiles to the direcotry where they are expected (usually, our home directory) 
ln -sv “~/.dotfiles/runcom/.bash_profile” ~
ln -sv “~/.dotfiles/runcom/.inputrc” ~
ln -sv “~/.dotfiles/git/.gitconfig” ~

# Apply settings to all terminal sessions without need of a restart
source ~/.bashrc

# Install brew and brew cast applications
log.info "Loading Brewfile ..."
brew bundle --file=/install/Brewfile

log.info "Loading Castfile ..."
brew bundle --file=/install/Castfile