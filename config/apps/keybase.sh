#!/usr/bin/env bash

# Make sure keybase is installed
# if brew cask ls --versions keybase > /dev/null; then
if keybase version > /dev/null; then
  # The package is installed, check version
  keybase version

  # Login and pull all secrets to local machine
  keybase login
  keybase fs cp -r keybase://private/andreffs18/.aws ~/.aws
  keybase fs cp keybase://private/andreffs18/.unbabel ~/.unbabel
  keybase fs cp keybase://private/andreffs18/.secrets ~/.secrets

  # Add new dotfiles to zshrc to be sourced when new terminal tab is opened
  cat << EOT >> ~/.zshrc

# Source Unbabel Secrets
source ~/.unbabel
# Source My Secrets
source ~/.secrets
EOT
  log.success "Keybase configured!"
else
  log.fail "😭 Keybase was not configured!"
fi
