#!/usr/bin/env bash

# Install pure prompt
npm install --global pure-prompt

# Add configurations to our ~/.zshrc
cat << EOT >> ~/.zshrc

# Pure Prompt Configuration
# more can be found here: https://github.com/sindresorhus/pure#getting-started
autoload -U promptinit; promptinit
# change the path color; change the color for both 'prompt:success' and 'prompt:error'
zstyle :prompt:pure:path color white
zstyle :prompt:pure:prompt:success color green
zstyle :prompt:pure:prompt:error color red
# make sure that we always show how much time each command took
PURE_CMD_MAX_EXEC_TIME=1
# configure pure prompt
prompt pure

# add k8s to left side of prompt and clean right side
PROMPT='$(kube_ps1) '$PROMPT
RPROMPT=''

EOT

log.success "Pure prompt configured!"
