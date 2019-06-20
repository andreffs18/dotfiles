#!/usr/bin/env bash
source ~/.logging

# Load all dotfiles one by one
for DOTFILE in ~/.{exports,aliases,functions,prompt,mansettings}; do
  [ -f "$DOTFILE" ] && source "$DOTFILE"
done

# Setup auto complete for kubectl client
# source <(kubectl completion zsh)
# security find-generic-password -wa Unbabel  

# Welcome message
source ~/.olhaaqui | lolcat

