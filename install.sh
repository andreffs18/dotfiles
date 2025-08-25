#!/usr/bin/env bash
export DIRECTORY=~/.dotfiles
export APPLE_ID=andreffs18@gmail.com
export REPOSITORY=https://github.com/andreffs18/dotfiles

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
  echo "🌀 Directory exists. Just pulling from repository..."
  pushd $DIRECTORY
  git pull origin master
  popd
else
  echo "✨ Directory does not exist. Creating it..."
  mkdir $DIRECTORY
  pushd $DIRECTORY
  git clone $REPOSITORY .
  popd
fi

# Now let's symlink all our dotfiles to the directory where they are expected (our home directory)
for FILE in $DIRECTORY/config/system/.*; do
  [ -f "$FILE" ] && ln -sfv $FILE ~
done

# Symlink all git configuration files to our home directory
# ln -sfv $DIRECTORY/config/git/.gitignore_global ~
# ln -sfv $DIRECTORY/config/git/.gitconfig ~


# Initialize dotfiles
source ~/.bashrc

# Setup MacOS settings for the first time
source $DIRECTORY/config/mac/osx

# Install brew and all apps on Brewfile, Caskfile and Masfile
source $DIRECTORY/install/apps

# Install and configure all apps that require custom setup
source $DIRECTORY/config/apps/oh-my-zsh
source $DIRECTORY/config/apps/brew
source $DIRECTORY/config/apps/pure-prompt
source $DIRECTORY/config/apps/keybase
source $DIRECTORY/config/apps/ssh
source $DIRECTORY/config/apps/exercism
source $DIRECTORY/config/apps/dockutil

# Install Lolcat for funz 😂 (https://github.com/busyloop/lolcat)
sudo gem install lolcat
log.success "$(lolcat --version)" | lolcat

# Reminder to install missing apps, suggest updating and restart
log.warning "Don't forget to install the following:\n👉  Exodus: https://www.exodus.io/download/\n👉  Final Cut Pro"
log.success "Mac os configured! 🔮\n To update software run 'sudo softwareupdate -i -a'."
log.success "Restarting computer..." | lolcat

sleep 10
log.success "👋"
sudo reboot
