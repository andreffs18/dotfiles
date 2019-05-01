#!/usr/bin/env bash
log.info "Loading .bash_profile ..."

# Load all dotfiles one by one
for DOTFILE in .{exports,aliases,functions,dircolor,prompt,inputrc,osx,mansettings,olhaaqui}; do
  [ -f "$DOTFILE" ] && source "$DOTFILE"
done

# Setup auto complete for kubectl client
source <(kubectl completion zsh)

# welcome message
log.success "Welcome to the dark side of the moon, $USER!"

# security find-generic-password -wa Unbabel  