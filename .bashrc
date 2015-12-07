## andreffs18's ~/.bashrc

###############################
### ENVIRONMENTAL VARIABLES ###
###############################

# Python virtual environments:
export WORKON_HOME=$HOME/.virtualenvs
export VIRTUALENVWRAPPER_VIRTUALENV_ARGS='--no-site-packages'
export PIP_VIRTUALENV_BASE=$WORKON_HOME
export PIP_RESPECT_VIRTUALENV=true
export PATH=$PATH:/usr/local/sbin

if [[ -r /usr/local/bin/virtualenvwrapper.sh ]]; then
    source /usr/local/bin/virtualenvwrapper.sh
else
    echo "WARNING: Can't find virtualenvwrapper.sh"
fi

# Added by the Heroku Toolbelt
export PATH="$PATH:/usr/local/heroku/bin"
# Add RVM to PATH for scripting
export PATH="$PATH:$HOME/.rvm/bin"

# PYTHONPATH=$PYTHONPATH:/Users/andresilva/Desktop/unbabelGithub/unbabel-utils
# PYTHONPATH=$PYTHONPATH:/Users/andresilva/Desktop/unbabelDocumentFormatter/unbabel-document-formatter
# PYTHONPATH=$PYTHONPATH:/Users/andresilva/Desktop/unbabelServer/unbabel
PYTHONPATH=$PYTHONPATH:
NLTK_DATA=/Users/andresilva/Desktop/unbabelServer/unbabel/nltk_data/

export PYTHONPATH NLTK_DATA
export PGHOST=localhost

##################
### MY ALIASES ###
##################
# Load custom alias
source ~/.myalias
# Load man settings
source ~/.mansettings
# Load custom prompt settings
source ~/.promptsettings


# welcome message
echo " "
echo "Welcome to the dark side of the moon, $USER!"
echo " "
