#Aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

#AWS
[ -f ~/.aws/credentials.env ] && source ~/.aws/credentials.env

#bash completion
[ -f $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

#bash history
shopt -s histappend

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

#JSON
json2yaml() {
  ruby -r yaml -r json -e 'puts JSON.load($stdin.read).to_yaml'
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
  [ -s "$HOME/git/dotfiles/bash_profile.d/nvm.sh" ] && \. "$HOME/git/dotfiles/bash_profile.d/nvm.sh"
fi

#RVM
[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"

#tab completion
[ -f $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

#tcl-tk
export PATH="$PATH:/usr/local/opt/tcl-tk/bin"

#virtualenvwrapper for Python 3
if [ -f /usr/local/bin/virtualenvwrapper.sh ]
then
  export VIRTUALENVWRAPPER_PYTHON=`which python3`
  source /usr/local/bin/virtualenvwrapper.sh
fi

#YAML
yaml2json () {
  ruby -r yaml -r json -e 'puts YAML.load($stdin.read).to_json'
}

[ -f ~/.profile ] && source ~/.profile

#direnv (yes this must be at the end)
#https://direnv.net/docs/hook.md
eval "$(direnv hook bash)"
