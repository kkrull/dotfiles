#Aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

#Editor
export VISUAL=vim
export EDITOR="$VISUAL"

#git
if [ -f "$(brew --prefix bash-git-prompt)/share/gitprompt.sh" ]; then
  GIT_PROMPT_THEME=Default
  source "$(brew --prefix bash-git-prompt)/share/gitprompt.sh"
fi

#less
export LESS='-iXR --shift 2'

#ls colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

#Tab completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

