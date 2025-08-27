#!/usr/bin/env bash

# Make sure keybase is installed
# if brew cask ls --versions keybase > /dev/null; then
if keybase version > /dev/null; then
  # The package is installed, check version
  keybase version

  # Login and pull all secrets to local machine
  keybase login

  kbpull

  # Add new dotfiles to zshrc to be sourced when new terminal tab is opened
  cat << EOT >> ~/.zshrc

# Source Unbabel Secrets
source ~/.unbabelconfigs/utils.sh
# Source My Secrets
source ~/.secrets
EOT
  log.success "Keybase configured!"
else
  log.fail "😭 Keybase was not configured!"
fi
