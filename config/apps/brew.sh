#!/usr/bin/env bash
# Add homebrew envs to terminal session
cat << EOT >> ~/.zshrc
# Brew Configuration
$($(which brew) shellenv)
EOT

# TODO: I need to check if I need this new way of configuring brew
# [[ -r "/opt/homebrew/bin/brew" ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
# export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"

log.success "Brew configured!"
