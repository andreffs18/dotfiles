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

# Now let's symlinc all our dotfiles to the directory where they are expected (our home directory) 
for DIR in $DIRECTORY/config/system/.{zshrc,bash_profile,bashrc,logging,exports,aliases,functions,prompt,mansettings,olhaaqui}; do
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

# Apply settings to all terminal sessions without need of a restart
if ! source ~/.zshrc; then
  log.fail "Failed to source .zshrc!"
fi

log.success "Mac os configured!"