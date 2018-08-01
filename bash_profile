#Aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

#AWS
[ -f ~/.aws/credentials.env ] && source ~/.aws/credentials.env

#bash completion
[ -f $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

#bin
[ -d ~/bin ] && export PATH="$HOME/bin:$PATH"

#editor
export VISUAL=vim
export EDITOR="$VISUAL"

#git
if [ -f "/usr/local/share/gitprompt.sh" ]; then
  GIT_PROMPT_FETCH_REMOTE_STATUS=0
  GIT_PROMPT_THEME=Default
  source "/usr/local/share/gitprompt.sh"
fi

#go
go version >/dev/null 2>&1
if (( $? == 0 ))
then
  export PATH="$PATH:$(go env GOPATH)/bin"
fi

#HTTP
parse_location() { 
  cat - | grep 'Location' | perl -p -e 's/Location:\s*(.*)$/\1/g'
}

#less
export LESS='-iXR --shift 2'

#ls colors
#alias ls='ls --color'
alias ls='ls -G'
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
#export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

#nvm
if [ -s "$HOME/.nvm" ]
then
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

#RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

#tab completion
[ -f $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

#tcl-tk
export PATH="$PATH:/usr/local/opt/tcl-tk/bin"

#virtualenvwrapper
[ -f /usr/local/bin/virtualenvwrapper.sh ] && source /usr/local/bin/virtualenvwrapper.sh

#YAML
yaml2json () {
  ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'
}

[ -f ~/.profile ] && source ~/.profile

