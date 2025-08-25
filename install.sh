#!/usr/bin/env bash
export DIRECTORY=~/.dotfiles
export APPLE_ID=andreffs18@gmail.com
export REPOSITORY=https://github.com/andreffs18/dotfiles

# Helper function to prompt user for confirmation
prompt_user() {
    local message="$1"
    echo ""
    echo "🤔 $message"
    read -p "   Press Y or Enter to continue, or any other key to skip: " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
        return 0
    else
        echo "⏭️  Skipping this step..."
        return 1
    fi
}

# Before everything, let's install the latest version of xcode and SignIn into appstore
# You can get more info about xcode here https://developer.apple.com/library/archive/technotes/tn2339/_index.html
if [[ "$(xcode-select --print-path > /dev/null 2>&1; echo $?)" -ne 0 ]]; then
  echo "🖥  Xcode not found... installing it!"
  echo "🚨 (re-run this script after xcode installation is complete) 🚨"
  xcode-select --install  >/dev/null 2>&1
  exit 1
fi

# Let's create the ~/.dotfiles folder to store cloned dotfiles
if [ -d "$DIRECTORY" ]; then
  if prompt_user "Directory exists. Pull latest changes from repository?"; then
    echo "🌀 Pulling from repository..."
    pushd $DIRECTORY
    git pull origin master
    popd
  fi
else
  if prompt_user "Directory does not exist. Clone dotfiles repository?"; then
    echo "✨ Creating directory and cloning repository..."
    mkdir $DIRECTORY
    pushd $DIRECTORY
    git clone $REPOSITORY .
    popd
  else
    echo "❌ Cannot continue without dotfiles repository. Exiting."
    exit 1
  fi
fi

# Symlink all git configuration files to our home directory
ln -sfv $DIRECTORY/config/git/.gitignore_global ~
ln -sfv $DIRECTORY/config/git/.gitconfig ~

# Now let's symlink all our dotfiles to the directory where they are expected (our home directory)
if prompt_user "Symlink dotfiles to home directory?"; then
    for FILE in $DIRECTORY/config/system/.*; do
      [ -f "$FILE" ] && ln -sfv $FILE ~
    done

    # Symlink all git configuration files to our home directory
    # ln -sfv $DIRECTORY/config/git/.gitignore_global ~
    # ln -sfv $DIRECTORY/config/git/.gitconfig ~
fi

# Initialize dotfiles
if prompt_user "Initialize dotfiles (source ~/.bashrc)?"; then
    source ~/.bashrc
fi

# Setup MacOS settings for the first time
if prompt_user "Apply MacOS system settings and preferences?"; then
    source $DIRECTORY/config/mac/osx
fi

# Install brew and all apps on Brewfile, Caskfile and Masfile
if prompt_user "Install Homebrew and all apps (Brewfile, Caskfile, Masfile)?"; then
    source $DIRECTORY/install/apps
fi

# Install and configure all apps that require custom setup
if prompt_user "Install and configure Oh My Zsh?"; then
    source $DIRECTORY/config/apps/oh-my-zsh.sh
fi

if prompt_user "Configure Homebrew settings?"; then
    source $DIRECTORY/config/apps/brew.sh
fi

if prompt_user "Install Pure prompt theme?"; then
  if ! whence -w prompt >/dev/null; then
    # `prompt` command not available → run your Pure prompt setup
    source "$DIRECTORY/config/apps/pure-prompt.sh"
  else
    log.info "Pure prompt already available, skipping installation."
  fi
fi

if prompt_user "Configure Keybase?"; then
    source $DIRECTORY/config/apps/keybase.sh
fi

if prompt_user "Configure SSH settings?"; then
    source $DIRECTORY/config/apps/ssh.sh
fi

if prompt_user "Install Exercism CLI?"; then
    source $DIRECTORY/config/apps/exercism.sh
fi

if prompt_user "Configure Dock utilities?"; then
    source $DIRECTORY/config/apps/dockutil.sh
fi

if prompt_user "Speed pasting on ZSH?"; then
    source $DIRECTORY/config/apps/speed-pasting-zsh.sh
fi

# Install Lolcat for funz 😂 (https://github.com/busyloop/lolcat)
if prompt_user "Install Lolcat gem for colorful output?"; then
    sudo gem install lolcat
    log.success "$(lolcat --version)" | lolcat
fi

# Reminder to install missing apps, suggest updating and restart
log.warning "Don't forget to install the following:\n👉  Exodus: https://www.exodus.io/download/\n👉  Final Cut Pro"
log.success "Mac os configured! 🔮\n To update software run 'sudo softwareupdate -i -a'."

# Prompt for final reboot
if prompt_user "Reboot computer to complete setup?"; then
    log.success "Restarting computer..." | lolcat
    sleep 10
    log.success "👋"
    sudo reboot
else
    log.success "Setup complete! You may want to reboot later to ensure all changes take effect."
fi
