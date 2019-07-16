# Dotfiles
My configuration files. 


## Installation
To setup a brand new macOS you just need to run the following one-liner:

```shell 
$ bash -c "`curl -fsSL https://raw.githubusercontent.com/andreffs18/dotfiles/master/install.sh`"
``` 

In case you want to revert this installation just run the "reset.sh" script:

```shell 
$ bash -c "`curl -fsSL https://raw.githubusercontent.com/andreffs18/dotfiles/master/reset.sh`"
``` 
> Note that this will only delete the `~/.dotfiles` folder and all symlinks. All installed apps will still be installed.

As this was tested on a macOS Sierra (10.12), I notice that the installation will partially fail since some apps are only available from macOS High Sierra (10.13). Make sure you have you're mac updated before running this.

## Functionality
- Focus functionality ```$ focus``` to start a 25 minute pomodoro + focus screen + spotify platlist + turn off notifications.
- zsh with [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh/wiki/Installing-ZSH) framework and [pure prompt](https://github.com/sindresorhus/pure) theme.
- [kitty](https://sw.kovidgoyal.net/kitty/index.html) terminal with [snazzy](https://github.com/connorholyday/kitty-snazzy) color scheme.

## Future
- Manage credentials https://keybase.io/docs/command_line or https://bitwarden.com/
- Add dotfiles as brew tap so we can install from [```"$ brew install andreffs18-dotfiles"```](https://docs.brew.sh/How-to-Create-and-Maintain-a-Tap).

## Credits
- Amazing OpenSource ["Mac Setup guide"](https://sourabhbajaj.com/mac-setup/), https://github.com/sb2nov/mac-setup/
- [Getting started with dotfiles](https://medium.com/@webprolific/getting-started-with-dotfiles-43c3602fd789) (by [L. Kappert](https://github.com/webpro))
- [Dotfiles are meant to be forked](https://zachholman.com/2010/08/dotfiles-are-meant-to-be-forked/) (by [Holman](https://github.com/holman/dotfiles))
- [awesome-dotfiles](https://github.com/webpro/awesome-dotfiles), a curated open source repo with a bunch of good examples.
- The top 3 most forked repos: [Paul Irish](https://github.com/paulirish/dotfiles), [Mathias Bynens](https://github.com/mathiasbynens/dotfiles) and [Lars Kappert](https://github.com/webpro/dotfiles)

and many thanks to the unofficial [dotfiles](https://dotfiles.github.io/) page 👍.




