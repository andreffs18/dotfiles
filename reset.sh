#!/usr/bin/env bash
# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until this script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Remove all symbolic links
rm ~/.aliases
rm ~/.bash_profile
rm ~/.bashrc
rm ~/.functions
rm ~/.global_exports
rm ~/.logging
rm ~/.mansettings
# "*" because we also want to delete backups (ie: ~/.zshrc.pre-...)
rm ~/.zshrc*
# Remove all git symlinks from our our home directory
rm ~/.gitignore_global
rm ~/.gitconfig
# Remove all config symlinks
rm ~/.config/flake8
echo "🗑  Removed symlinks"

# Remove oh-my-zsh framework
rm -rf ~/.oh-my-zsh
rm -rf ~/.zsh
echo "🗑  Removed oh-my-zsh framework"

# Finish by removing the ~/.dotfiles directory!
rm -rf ~/.dotfiles
echo "🗑  Removed ~/.dotfiles folder"

# Remove .emoji/ folder which is added for the `$ olhaaqui` command
rm -rf ~/.emoji
echo "🗑  Removed ~/.emoji folder"

# Remove configs and secrets folder/files
rm -rf ~/.aws
rm -rf ~/.ssh
echo "🗑  Removed config folders (.aws and .ssh)"
rm ~/.unbabel
rm ~/.secrets
echo "🗑  Removed secrets (.unbabel and .secrets)"

# Remove installed apps
yes | sudo gem uninstall lolcat && which lolcat

echo "🥃  and that's it!"
