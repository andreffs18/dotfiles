#!/usr/bin/env bash
export DIRECTORY=~/.dotfiles
export APPLE_ID=andreffs18@gmail.com

# Before everything, let's install the latest version of xcode and SignIn into appstore
# You can get more info about xcode here https://developer.apple.com/library/archive/technotes/tn2339/_index.html
if [[ "$(xcode-select --print-path > /dev/null 2>&1; echo $?)" -ne 0 ]]; then
  echo "🖥  Xcode not found... installing it!"
  echo "🚨 (re-run this script after xcode installation is complete) 🚨"
  xcode-select --install  >/dev/null 2>&1
  exit 1
fi

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

# Now let's symlinc all our dotfiles to the directory where they are expected (our home directory)
for DIR in $DIRECTORY/config/system/.*; do
  [ -f "$DIR" ] && ln -sfv $DIR ~
done

# Symlink all git configuration files to our home directory
ln -sfv $DIRECTORY/config/git/.gitignore_global ~
ln -sfv $DIRECTORY/config/git/.gitconfig ~

# Create .config folder, if it doens't exist already
CONFIG_DIRECTORY=~/.config
if [ ! -d "$CONFIG_DIRECTORY" ]; then
  mkdir "$CONFIG_DIRECTORY";
fi
# Symlink python linting flake8 configuration
ln -sfv $DIRECTORY/config/python/flake8 $CONFIG_DIRECTORY

# Initialize Logging
source ~/.logging

# Setup MacOS settings for the first time
source $DIRECTORY/config/mac/osx

# Install brew and all apps on Brewfile, Caskfile and Masfile
source $DIRECTORY/install/apps

# Update mac os software and restart mac
log.success "Mac os configured! Updating software and restarting afterwards! 🔮"
sudo softwareupdate -i -a --restart
