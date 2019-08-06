#!/usr/bin/env bash
DIRECTORY=~/.dotfiles
APPLE_ID=andreffs18@gmail.com

# Before everything, let's install the latest version of xcode and SignIn into appstore
# if [ "$(xcode-select -p 1>/dev/null;echo $?)" -eq "0" ]; then
# You can get more info about xcode here https://developer.apple.com/library/archive/technotes/tn2339/_index.html
if [[ ! "$(xcode-select -p)" ]]; then 
  echo "🖥  Installing xcode ..."
	xcode-select --install
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
if ! source $DIRECTORY/config/mac/osx; then
  log.fail "Failed to source config/mac/osx configuration!"
fi

# Install brew and all apps on Brewfile, Caskfile and Masfile
if ! source $DIRECTORY/install/apps; then
   log.fail "Failed to source install/apps instalation!"
fi

# Update mac os software and restart mac
log.success "Mac os configured! Updating software and restarting afterwards! 🔮"
sudo softwareupdate -i -a --restart