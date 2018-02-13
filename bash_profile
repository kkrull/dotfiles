#Aliases
if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

#AWS
#[ -f ~/.aws/credentials.env ] && source ~/.aws/credentials.env

#bin
[ -d ~/bin ] && export PATH="$HOME/bin:$PATH"

#editor
export VISUAL=vim
export EDITOR="$VISUAL"

#git
#if [ -f "/usr/local/share/gitprompt.sh" ]; then
#  GIT_PROMPT_FETCH_REMOTE_STATUS=0
#  GIT_PROMPT_THEME=Default
#  source "/usr/local/share/gitprompt.sh"
#fi

#GNU coreutils
#export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
#alias ls='ls --color'

#less
export LESS='-iXR --shift 2'

#ls colors
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

#tab completion
if [ -f $(brew --prefix)/etc/bash_completion ]; then
  . $(brew --prefix)/etc/bash_completion
fi

#virtualenvwrapper
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

#YAML
yaml2json () {
        ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'
}

#RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

source ~/.profile
