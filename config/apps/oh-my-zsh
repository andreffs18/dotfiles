#!/usr/bin/env bash

# Download oh-my-zsh framework
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) -s --unattended"

# Overwrite installed .zshrc from oh-my-zsh with my own
ln -sfv $DIRECTORY/config/system/.zshrc ~

# Download plugins (DON'T FORGET, in case you want to add more, to add them to list of "plugins" on ~/.dotfiles/config/system/.zshrc!)
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions

# Print zsh version
log.success "Installed oh-my-zsh on $(zsh --version)!"
