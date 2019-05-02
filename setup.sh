#!/usr/bin/env bash

DIRECTORY=~/.dotfiles

# Let's create the ~/.dotfiles folder to store cloned dotfiles
if [ -d "$DIRECTORY" ]; then
  echo "Directory exists. Just pulling from repository..."
  cd $DIRECTORY
  git pull origin master
else
  echo "Directory does not exist..."
  mkdir $DIRECTORY && cd $DIRECTORY
  git clone https://github.com/andreffs18/dotfiles .
fi

# Now let's symlinc all our dotfiles to the direcotry where they are expected (usually, our home directory) 
for DIR in $DIRECTORY/.{bash_profile,bashrc,logging,exports,aliases,functions,prompt,mansettings,olhaaqui}; do
  [ -f "$DIR" ] && ln -sfv $DIR ~
done

# Symlink MacOS initial configuration
ln -sfv $DIRECTORY/config/mac/.osx ~

# Symlink all git configuration files
ln -sfv $DIRECTORY/config/git/.gitignore_global ~
ln -sfv $DIRECTORY/config/git/.gitconfig ~

# Symlink python linting flake8 configuration 
if [ ! -d ~/.config/ ]; then
  mkdir ~/.config/;
fi
ln -sfv $DIRECTORY/config/python/flake8 ~/.config/flake8

# Initialize Logging
source ~/.logging

# Setup MacOS settings for the first time
source ~/.osx

# Apply settings to all terminal sessions without need of a restart
source ~/.bash_profile

# Install brew and brew cast applications
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew update

log.info "Loading Brewfile ..."
brew bundle --file=$DIRECTORY/install/Brewfile

log.info "Loading Castfile ..."
brew bundle --file=$DIRECTORY/install/Castfile

log.success "Mac os configured!"
