#Aliases
[ -f ~/.bash_aliases ] && source ~/.bash_aliases

#AWS
[ -f ~/.aws/credentials.env ] && source ~/.aws/credentials.env

#bash completion
[ -f $(brew --prefix)/etc/bash_completion ] && source $(brew --prefix)/etc/bash_completion

#bash history
shopt -s histappend

#bin
[ -d "$HOME/bin" ] && export PATH="$HOME/bin:$PATH"

#cassandra
if [ -d /usr/local/opt/cassandra@2.2 ]
then
  export CASSANDRA_CONTACTPOINTS=172.10.10.1
  export PATH="/usr/local/opt/cassandra@2.2/bin:$PATH"
fi

#dockhub
if [ -d "$HOME/grubhub/dockhub" ]
then
  #https://github.com/GrubhubProd/dockhub/blob/master/docs/environment.md#set-path-and-environment-variables
  export PATH="$PATH:$HOME/grubhub/dockhub/bin"
fi

#editor
export VISUAL=vim
export EDITOR="$VISUAL"

#git
if [ -f "/usr/local/share/gitprompt.sh" ]
then
  GIT_PROMPT_FETCH_REMOTE_STATUS=0
  GIT_PROMPT_THEME=Default
  source "/usr/local/share/gitprompt.sh"
fi

#gh-dev
if [ -d "$HOME/grubhub/gh-dev" ]
then
  for f in $HOME/grubhub/gh-dev/etc/*; do
    source $f
  done
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
alias ls='ls -G'
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced
#export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"

#mysql
[ -d '/usr/local/opt/mysql@5.7' ] && export PATH="/usr/local/opt/mysql@5.7/bin:${PATH}"

#nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

#Ruby: https://stackoverflow.com/questions/40597488/ruby-too-many-open-files-rb-sysopen
ulimit -n 8192

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
