#!/usr/bin/env bash
source ~/.logging

# Load all dotfiles one by one
for DOTFILE in ~/.{exports,aliases,functions,mansettings}; do
  [ -f "$DOTFILE" ] && source "$DOTFILE"
done

# Welcome message
olhaaqui
