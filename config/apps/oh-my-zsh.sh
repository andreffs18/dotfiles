#!/usr/bin/env bash

# Download oh-my-zsh framework
sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh) -s --unattended"

# Overwrite installed .zshrc from oh-my-zsh with my own
ln -sfv $DIRECTORY/config/system/.zshrc ~

# (DON'T FORGET, in case you add more custom plugins, to add them to the "plugins" list on ~/.dotfiles/config/system/.zshrc!)
[[ -d ~/.oh-my-zsh/custom/plugins/zsh-completions ]] || git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions

# Print zsh version
log.success "Installed oh-my-zsh on $(zsh --version)!"
