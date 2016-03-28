#Aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

#Editor
export VISUAL=vim
export EDITOR="$VISUAL"

#less
export LESS='-iXR --shift 2'

#ls colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

#Tab completion [brew bash-completion]
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

