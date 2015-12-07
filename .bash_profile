clear
# Load the default .profile
[[ -s "$HOME/.profile" ]] && source "$HOME/.profile"
# Load RVM into a shell session *as a function*
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

##
# Your previous /Users/andresilva/.bash_profile file was backed up as /Users/andresilva/.bash_profile.macports-saved_2015-08-13_at_11:20:13
##

# MacPorts Installer addition on 2015-08-13_at_11:20:13: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"
# Finished adapting your PATH environment variable for use with MacPorts.

