#!/usr/bin/env bash
EXERCISM_DIR=~/projects/exercism

if [ -z "${EXERCISM_TOKEN+x}" ]; then
  log.info "EXERCISM_TOKEN is unset, loading from ~/.secrets"
  source "~/.secrets"
fi


# Make sure exercism is installed
if brew ls --versions exercism > /dev/null; then
  # The package is installed
  exercism version
  # Setup exercism on expected folder
  exercism configure --token=$EXERCISM_TOKEN --workspace $EXERCISM_DIR
  # Pull repo from github
  if [ ! -d "$EXERCISM_DIR" ]; then
    mkdir -p $DIRECTORY
    git clone git@github.com:andreffs18/Exercism.git $EXERCISM_DIR
  else
    pushd $EXERCISM_DIR
    git pull origin master
    popd
  fi
  log.success "Exercism configured!"
else
  log.fail "😭 Exercism was not installed"
fi
