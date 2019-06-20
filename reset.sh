#!/usr/bin/env bash

# Let's start by removing the ~/.dotfiles directory!
rm -rf ~/.dotfiles
echo "❎  ~/.dotfiles folder"
# Now, remove all symbolic links 
for DIR in ~/.{aliases,bash_profile,bashrc,dockutil,exports,functions,gitconfig,gitignore_global,logging,mansettings,olhaaqui,osx,prompt,zshrc}; do
  [ -f "$DIR" ] && rm $DIR
  echo "❎  Removed symlink $DIR"
done

# Remove links in /config folder
rm ~/.config/flake8
echo "❎  Removed python config/flake8 configuration"

# Remove oh-my-zsh framework
rm -rf ~/.oh-my-zsh
echo "❎  Removed oh-my-zsh framework"

echo "🗑  and I think that's it!"