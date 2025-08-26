#!/usr/bin/env bash

# 1) Import (this replaces the domain with your file's contents)
defaults import com.knollsoft.Rectangle $DIRECTORY/config/mac/rectangle.plist

# 2) Flush Apple’s prefs cache and relaunch
killall cfprefsd
open -a Rectangle

log.success "Rectangle configured!"
