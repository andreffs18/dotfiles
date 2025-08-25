#!/usr/bin/env bash
# Add homebrew envs to terminal session
cat << EOT >> ~/.zshrc
# Brew Configuration
$(which brew) shellenv
EOT

log.success "Brew configured!"
