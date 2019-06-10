#!/usr/bin/env bash
source ~/.logging

# Load all dotfiles one by one
for DOTFILE in .{exports,aliases,functions,prompt,mansettings,olhaaqui}; do
  [ -f "$DOTFILE" ] && source "$DOTFILE"
done

# Setup auto complete for kubectl client
# source <(kubectl completion zsh)

# welcome message
log.success "Welcome to the dark side of the moon, $USER!"

# security find-generic-password -wa Unbabel  