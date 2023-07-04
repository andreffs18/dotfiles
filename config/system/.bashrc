#!/usr/bin/env bash

# Load all dotfiles one by one
# (~/.logging takes precendence since all other alias depend on it)
source ~/.logging

source ~/.aliases
source ~/.functions
source ~/.global_exports
source ~/.mansettings

##############################################################
# User configuration
##############################################################
