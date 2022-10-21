#!/usr/bin/env bash

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Let's start by removing the ~/.dotfiles directory!
sudo rm -rf ~/.dotfiles
echo "❎  ~/.dotfiles folder"
# Now, remove all symbolic links
for DIR in ~/.{aliases,bash_profile,bashrc,dockutil,exports,functions,gitconfig,gitignore_global,logging,mansettings,olhaaqui,osx,zshrc}; do
  sudo rm $DIR
  echo "❎  Removed symlink $DIR"
done

# Remove links in /config folder
sudo rm ~/.config/flake8
echo "❎  Removed python config/flake8 configuration"

# Remove oh-my-zsh framework
sudo rm -rf ~/.oh-my-zsh
echo "❎  Removed oh-my-zsh framework"

echo "🗑  and I think that's it!"
